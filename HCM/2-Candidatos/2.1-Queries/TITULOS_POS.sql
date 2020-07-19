SELECT
	BASE_0.PROFILE_ID
	,BASE_1.CONTENT_TYPE_ID
	,BASE_1_2.CONTENT_TYPE_NAME
	,BASE_1.CONTENT_ITEM_ID
	,BASE_1_1.NAME
	,BASE_0.ITEM_TEXT240_1 ITEM_DESCRIPTION
	--,BASE_1_1.ITEM_DESCRIPTION
	,BASE_1.CONTENT_VALUE_SET_ID
	,BASE_1.CONTENT_ITEM_CODE
	,BASE_1.RATING_MODEL_ID
	,BASE_1.ITEM_TEXT_22
FROM 
	HRT_PROFILE_ITEMS BASE_0
	,HRT_CONTENT_ITEMS_B BASE_1
	,HRT_CONTENT_ITEMS_TL BASE_1_1
	,HRT_CONTENT_TYPES_TL BASE_1_2
WHERE
	BASE_1.CONTENT_ITEM_ID = BASE_0.CONTENT_ITEM_ID
	AND BASE_1_1.CONTENT_ITEM_ID = BASE_1.CONTENT_ITEM_ID
	And BASE_1_1.LANGUAGE = USERENV ('LANG')
	And BASE_0.CONTENT_TYPE_ID = 106 -- Títulos
	AND BASE_1_2.CONTENT_TYPE_ID = BASE_1.CONTENT_TYPE_ID
	And BASE_1_2.LANGUAGE = USERENV ('LANG')