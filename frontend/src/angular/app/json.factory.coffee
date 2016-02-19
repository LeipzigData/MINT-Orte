angular
.module("app.services")
.factory "JsonData", ($resource, $cacheFactory) ->
	localCache = $cacheFactory('JsonData')
	$idents=
		angebot: "http://leipzig-data.de/Data/MINT-2014/Angebot"
		schwerpunkt: "http://leipzig-data.de/Data/MINT-2014/Schwerpunkt"
		ortsbeschreibung: "http://leipzig-data.de/Data/MINT-2014/Ortsbeschreibung"
		orte: "http://leipzig-data.de/Data/Model/Ort"
		tags: "http://leipzig-data.de/Data/Model/Tag"
		GeoDaten: "http://leipzig-data.de/Data/Model/Adresse"
		stadtteile: "http://leipzig-data.de/Data/Model/Ortsteil"
		stdModelNamespace: "http://leipzig-data.de/Data/Model/"

	extractObjects = (data, ident) ->
		returnObj1 =
			data:{}
			valueSets: {}
		for dataset in data
			for set in dataset when set["@type"]? and set["@type"][0] is ident
				setObject={}
				setObject._id= set["@id"]
				parts=set["@id"].split('/')
				setObject._shortId = parts[parts.length-1]
				setObject._type= set["@type"][0]
				if set["http://www.w3.org/2000/01/rdf-schema#label"]?
					setObject._label= set["http://www.w3.org/2000/01/rdf-schema#label"][0]["@value"]
				if set["http://www.w3.org/2000/01/rdf-schema#comment"]?
					setObject._comment= set["http://www.w3.org/2000/01/rdf-schema#comment"][0]["@value"]

				for key, value of set when typeof value isnt "function" and key.indexOf('http://') is 0
					if key is "http://www.w3.org/2000/01/rdf-schema#label" or key is "http://www.w3.org/2000/01/rdf-schema#comment" then continue
					temp =key.split('/')
					elementName = temp[temp.length-1]
					setObject[elementName] =[]
					if value.length is 1 and value[0]["@value"]?
						setObject[elementName] = value[0]["@value"]
					else
						for valueValue, valueKey in value
							if valueValue["@value"]?
								if not returnObj1.valueSets[elementName]?
									returnObj1.valueSets[elementName] = [valueValue["@value"]]
								else if returnObj1.valueSets[elementName].indexOf(valueValue["@value"]) is -1
									returnObj1.valueSets[elementName].push valueValue["@value"]
								#else
									#console.log valueValue["@value"], "already exist in valueSets"
								setObject[elementName].push value[valueKey]["@value"]
							else if valueValue["@id"]?
								setObject[elementName].push {"_id" : valueValue["@id"]}
							else
								console.log "not @id and @value", valueKey, valueValue
				returnObj1.data[setObject._id] = setObject
		returnObj1

	res = $resource "data/:fileName",
		fileName: "@fileName"
	,
		query:
			isArray: true

			cache: localCache
	res.convert = (data) ->
		if not angular.isUndefined localCache.get("convertedData")
			# console.log "isCached"
			return localCache.get "convertedData"

		returnObj ={}


		returnObj.angebote=extractObjects(data, $idents.angebot)
		returnObj.ortsbeschreibung=extractObjects(data, $idents.ortsbeschreibung)
		returnObj.orte=extractObjects(data, $idents.orte)
		returnObj.geoDaten=extractObjects(data, $idents.GeoDaten)
		returnObj.tags=extractObjects(data, $idents.tags)
		returnObj.stadtteile=extractObjects(data, $idents.stadtteile)
		returnObj.schwerpunkte=extractObjects(data, $idents.schwerpunkt)
		returnObj.stadtteile.valueSets = []

		targetArray=[]
		#Angebote
		for key, angebot of returnObj.angebote.data
			angebotID =angebot.relatedBundle[0]["_id"]
			if not returnObj.ortsbeschreibung.data[angebotID]? then continue #Angebot an unbekanntem Ort
			if angebot['hasTag']?
				angebot['hasTagIds'] = []
				for tag in angebot['hasTag'] when returnObj.tags.data[tag._id]?
					temp =returnObj.tags.data[tag._id]._id.split('/')
					id = temp[temp.length-1]
					angebot['hasTagIds'].push id
				delete angebot['hasTag']
			delete returnObj.angebote.data[key].relatedBundle
			if not returnObj.ortsbeschreibung.data[angebotID].hasAngebote?
				returnObj.ortsbeschreibung.data[angebotID].hasAngebote = []
			returnObj.ortsbeschreibung.data[angebotID].hasAngebote.push returnObj.angebote.data[key]
		#schwerpunkte
		for key, schwerpunkt of returnObj.schwerpunkte.data
			schwerpunktID =schwerpunkt.relatedBundle[0]["_id"]
			if not returnObj.ortsbeschreibung.data[schwerpunktID]?
				# console.log "No Ortsbeschreibung found for: ", schwerpunktID
				continue #schwerpunkt an unbekanntem Ort
			if schwerpunkt['hasTag']?
				schwerpunkt['hasTagIds'] = []
				for tag in schwerpunkt['hasTag'] when returnObj.tags.data[tag._id]?
					temp =returnObj.tags.data[tag._id]._id.split('/')
					id = temp[temp.length-1]
					schwerpunkt['hasTagIds'].push id
				delete schwerpunkt['hasTag']
			delete returnObj.schwerpunkte.data[key].relatedBundle
			if not returnObj.ortsbeschreibung.data[schwerpunktID].hasSchwerpunkte?
				returnObj.ortsbeschreibung.data[schwerpunktID].hasSchwerpunkte = []
			returnObj.ortsbeschreibung.data[schwerpunktID].hasSchwerpunkte.push returnObj.schwerpunkte.data[key]

		# console.log returnObj
		targetArray=[]
		iterator=0
		for key, MintOrt of returnObj.ortsbeschreibung.data
			tempObject= {}
			tempObject.id=iterator++
			#atomare Felder
			# fields = ['Fax', 'Internet', 'Kurzinformation','Leistungsangebot']
			fields = Object.keys(MintOrt)
			for field in fields
			#	console.log "fields-Iterator:", field, MintOrt[field]
				if MintOrt[field]? and field not in ['hasTag', 'describes', 'hasAngebote', 'hasSchwerpunkte', 'Internet'] and MintOrt[field].length is 1 #Atomare Felder
					tempObject[field] = MintOrt[field][0]
				else if field is "hasTag"
					tempObject['hasTagIds'] = []
					for tag in MintOrt[field] when returnObj.tags.data[tag._id]?
						temp =returnObj.tags.data[tag._id]._id.split('/')
						id = temp[temp.length-1]
						tempObject['hasTagIds'].push id
				else if field is "Internet"
					tempObject['Internet'] = []
					if typeof MintOrt[field] is "object"
						for url in MintOrt[field]
							tempObject['Internet'].push url
					else
						tempObject['Internet']=[MintOrt[field]]

				else if field is "describes"
					# console.log "describes:", MintOrt[field].length if MintOrt[field].length>1
					if returnObj.orte.data[MintOrt[field][0]._id]?
						delete returnObj.orte.data[MintOrt[field][0]._id].relatedBundle
						delete returnObj.orte.data[MintOrt[field][0]._id].hasTag
						delete returnObj.orte.data[MintOrt[field][0]._id].engagedPerson
						delete returnObj.orte.data[MintOrt[field][0]._id].contactPerson
						delete returnObj.orte.data[MintOrt[field][0]._id].hasSupplier
						delete returnObj.orte.data[MintOrt[field][0]._id].hasStatus
						tempObject['Ort']=returnObj.orte.data[MintOrt[field][0]._id]
						if tempObject['Ort'].hasURL?
							for tURL in tempObject['Ort'].hasURL
								if not tURL? then continue
								if not tempObject['Ort'].url?
									tempObject['Ort'].url=[]
								tempObject['Ort'].url.push tURL['_id']
						delete tempObject['Ort']['hasURL']
						# find Address
						if tempObject['Ort']['hasAddress']? and tempObject['Ort']['hasAddress'][0]? and returnObj.geoDaten.data[tempObject['Ort']['hasAddress'][0]._id]?
							tempObject['Ort']['hasAddress'] = returnObj.geoDaten.data[tempObject['Ort']['hasAddress'][0]._id]
							#console.log "inOrtsteil", tempObject['describes']['hasAddress']['inOrtsteil'].length
							obj= tempObject['Ort']['hasAddress']['inOrtsteil']
							#console.log obj[0], returnObj.stadtteile.data[obj[0]._id]
							if obj? and obj[0]? and returnObj.stadtteile.data[obj[0]._id]?
								stadtteilname= returnObj.stadtteile.data[obj[0]._id]._label
								returnObj.stadtteile.valueSets.push stadtteilname if returnObj.stadtteile.valueSets.indexOf stadtteilname is -1
								tempObject['Ort']['hasAddress'].stadtteil =stadtteilname

								delete tempObject['Ort']['hasAddress']['inOrtsteil']
								delete tempObject['Ort']['hasAddress']['ontology#nearbyFeatures']
								delete tempObject['Ort']['hasAddress']['geosparql#asWKT']
								delete tempObject['Ort']['hasAddress']['inStreet']


							#console.log tempObject['describes']['hasAddress']
						# else
						# 	console.log "no Address"
				else
					# console.log "NOT IN", field, "->", MintOrt[field]
					tempObject[field] = MintOrt[field]

			targetArray.push tempObject


		# for set in data when set["@type"]? and set["@type"][0] isnt $idents.angebot and  set["@type"][0] isnt $idents.ortsbeschreibung
		# 	console.log set
		localCache.put "convertedData", targetArray
		# console.log returnObj, targetArray
		return targetArray
	res.getData = (cb, cached) ->
		me = this
		if not cached?
			cached = true
		if cached
			me.query
				fileName: "MINTBroschuere2014_aggregated.json"
			, (data) ->
				cb(data)
			return
		resArray=[]
		test= () ->
			if resArray.length is 2
				dataRes = res.convert resArray
				resArray =null
				# console.log "dataRes", dataRes
				cb dataRes
		me.query
			fileName: "MINTBroschuere2014.json"
		, (dataMINTBroschuere2014) ->
			resArray.push dataMINTBroschuere2014
			test()
		me.query
			fileName: "LeipzigDataExtract.json"
		, (dataAdressenGeodatenOrte) ->
			resArray.push dataAdressenGeodatenOrte
			test()

	res
