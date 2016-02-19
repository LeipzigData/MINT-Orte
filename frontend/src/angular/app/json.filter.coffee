angular
.module("app.services")
.filter "jsonFilter", () ->
	(input, filterObject) ->
		if not input? then return input
		searchString = (element) ->
			# console.log filterObject.searchString
			#No String given
			if filterObject.searchString is ""
				return true
			#String in label?
			if element._label? and element._label.toLowerCase().indexOf(filterObject.searchString.toLowerCase())>-1
				return true
			# Search in Angeboten
			if element.hasAngebote?
				for key, angebot of element.hasAngebote
					if angebot._label? and angebot._label.toLowerCase().indexOf(filterObject.searchString.toLowerCase())>-1
						return true
					if angebot.Zielstellung?
						for value1 in angebot.Zielstellung
							if value1.toLowerCase().indexOf(filterObject.searchString.toLowerCase())>-1
								return true
					if angebot.email?
						for value1 in angebot.email
							if value1.toLowerCase().indexOf(filterObject.searchString.toLowerCase())>-1
								return true
		searchTags = (element) ->
			if filterObject.all then return true
			if filterObject.tech and element.hasTagIds?.indexOf("Technik")>-1 then return true
			if filterObject.environment and element.hasTagIds?.indexOf("Umweltbildung")>-1 then return true
			if filterObject.nature and element.hasTagIds?.indexOf("Naturwissenschaft")>-1 then return true
			if filterObject.math and element.hasTagIds?.indexOf("Mathematik")>-1 then return true
			if filterObject.computer and element.hasTagIds?.indexOf("Informatik")>-1 then return true
			if filterObject.job and element.hasTagIds?.indexOf("Berufsorientierung")>-1 then return true
			return false
		searchStadtteil = (element) ->
			if filterObject.stadtteile.length is 0 then return true
			if not element.Ort? then return false
			if not element.Ort.hasAddress? then return false
			if not element.Ort.hasAddress.stadtteil? then return false
			if filterObject.stadtteile.indexOf(element.Ort.hasAddress.stadtteil) > -1
				return true
			return false
		searchGta = (element) ->
			if filterObject.gta is false then return true
			if element.hasTagIds?.indexOf("GTA")>-1
				return true
		searchHandicappedSuited = (element) ->
			if filterObject.handicappedSuited is 0 then return true
			if filterObject.handicappedSuited is 1 and (element.hasTagIds?.indexOf("BehiGe")>-1 or element.hasTagIds?.indexOf("EinBehiGe")>-1)
				return true
			if filterObject.handicappedSuited is 2 and (element.hasTagIds?.indexOf("BehiGe")>-1)
				return true

			return false

		returnArray=[]
		# console.log "FilterInput:", input, filterObject
		for key, element of input
			# console.log "search in ", element, "for",  filterObject.searchString
			if searchString(element) and searchTags(element) and searchStadtteil(element) and searchGta(element) and searchHandicappedSuited(element)
				returnArray.push element

		# console.log returnObj
		returnArray
