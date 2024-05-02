# bicep-aoai-private-rag-quickstarter
Bicep in this repository deploys the private RAG architecture like image bellow.
![](/imgs/private-rag-architecture.png)

## Caution
Possiblly using the `2024-03-01-Preview` ver API to deploy shared private link from Azure AI Search to Azure OpenAI Service, the process shows the error from the second deploy onwards.

```
[{"code":"BadRequest","message":"When updating a shared private link resource, only 'requestMessage' property is allowed to be modified RequestId: c139ebd3-3ae6-4922-99bd-588a182261dc"}]
```

![](/imgs/sharedpe-error-aoai.png)

# Notes
- After deployment you have to approve the shared private link created by Azure AI Search on storage account and Azure OpenAI Service.
- The shared private link from Azure OpenAI Service to Azure AI Search needs application. 
	- Follow this instruction and fill out the form.
		- Explanation: https://learn.microsoft.com/ja-jp/azure/ai-services/openai/how-to/use-your-data-securely#disable-public-network-access-1
		- Form: https://forms.office.com/pages/responsepage.aspx?id=v4j5cvGGr0GRqy180BHbRw_T3EIZ1KNCuv_1duLJBgpUMUcwV1Y5QjI3UTVTMkhSVUo3R09NNVQxSyQlQCN0PWcu

