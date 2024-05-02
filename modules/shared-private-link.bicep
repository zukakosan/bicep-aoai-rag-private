param aiSearchName string
param strgId string
param aoaiId string

var requestMessage = aiSearchName
var strgSharedPeName = 'shared-pe-strg'
var aoaiSharedPeName = 'shared-pe-aoai'

// // AOAI 用共有プライベートリンクが何も変更していないのに 2 回目以降の実行でエラーを吐いてしまうため、回避策として既存の共有プライベートリンクが存在するか確認する
// @description('check if the shared private link for AOAI already exists')
// var aoaiSharedPeIdExist = filter(aiSearch.properties.sharedPrivateLinkResources, pe => pe.name == aoaiSharedPeName)[0] != null

resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: aiSearchName
}

resource strgSharedPrivateLink 'Microsoft.Search/searchServices/sharedPrivateLinkResources@2023-11-01' = {
  name: strgSharedPeName
  parent: aiSearch
  properties: {
    groupId: 'blob'
    privateLinkResourceId: strgId
    requestMessage: requestMessage
  }
}

// 2024-03-01-Preview only supports shared private link for AOAIs
resource aoaiSharedPrivateLink 'Microsoft.Search/searchServices/sharedPrivateLinkResources@2024-03-01-Preview' = {
  name: aoaiSharedPeName
  parent: aiSearch
  properties: {
    groupId: 'openai_account'
    privateLinkResourceId: aoaiId
    requestMessage: requestMessage
  }
  dependsOn: [strgSharedPrivateLink]
}
