﻿using bravo_proxy_service.Dtos;
using bravo_proxy_service.Services.Persistancy.Handlers.List.Dtos;
using Newtonsoft.Json;

namespace bravo_proxy_service.Services.Persistancy.Handlers.List;

public interface IListValueHandler
{
    Task<ListValueResponseDto> Run();
}

public class ListValueHandler : IListValueHandler
{
    private const string PERSISTANCY_LIST_URI =
        "http://persistancy.bravo.svc.cluster.local:8080/persistancy/list";

    private readonly ILogger<ListValueHandler> _logger;

    private readonly HttpClient _httpClient;

    public ListValueHandler(
        ILogger<ListValueHandler> logger,
        IHttpClientFactory factory
    )
    {
        _logger = logger;

        _httpClient = factory.CreateClient();
    }

    public async Task<ListValueResponseDto> Run()
    {
        var responseMessage = PerformHttpRequest();
        return await ParseResponseMessage(responseMessage);
    }

    private HttpResponseMessage PerformHttpRequest()
    {
        _logger.LogInformation("Performing web request...");

        var httpRequest = new HttpRequestMessage(
            HttpMethod.Get,
            PERSISTANCY_LIST_URI
        );

        var response = _httpClient.Send(httpRequest);

        _logger.LogInformation("Web request is performed successfully");

        return response;
    }

    private async Task<ListValueResponseDto> ParseResponseMessage(
        HttpResponseMessage responseMessage
    )
    {
        _logger.LogInformation("Parsing response DTO...");
        var responseBody = await responseMessage.Content.ReadAsStringAsync();

        _logger.LogInformation($"Response body: {responseBody}");

        var responseDto = JsonConvert.DeserializeObject<ResponseDto<ListValueResponseDto>>(responseBody);
        _logger.LogInformation("Response DTO is parsed successfully");

        return responseDto.Data;
    }
}

