@String.prototype.removeTagsExcept = (tagNames)->
	whiteList = tagNames.map( (t)->
		'\/?' + t
	).join('|')
	regexp = new RegExp("<\/\?(?!#{whiteList})[^>]*>", 'ig')
	@replace regexp, ''