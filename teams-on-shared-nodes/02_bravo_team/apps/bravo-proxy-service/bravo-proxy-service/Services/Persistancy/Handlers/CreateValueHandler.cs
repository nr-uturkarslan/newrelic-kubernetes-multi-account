using System.Text;
using bravo_proxy_service.Dtos;
using bravo_proxy_service.Services.Persistancy.Data;
using bravo_proxy_service.Services.Persistancy.Dtos;
using Newtonsoft.Json;

namespace bravo_proxy_service.Services.Persistancy.Handlers;

public interface ICreateValueHandler
{
    Task<ValueEntity> Run(
        CreateValueRequestDto requestDto
    );
}

public class CreateValueHandler : ICreateValueHandler
{
    private const string PERSISTANCY_CREATE_URI =
        "http://persistancy.bravo.svc.cluster.local:8080/persistancy/create";

    private readonly ILogger<CreateValueHandler> _logger;

    private readonly HttpClient _httpClient;

    public CreateValueHandler(
        ILogger<CreateValueHandler> logger,
        IHttpClientFactory factory
    )
    {
        _logger = logger;

        _httpClient = factory.CreateClient();
    }

    public async Task<ValueEntity> Run(
        CreateValueRequestDto requestDto
    )
    {
        var requestDtoAsString = ParseRequestDto(requestDto);
        var responseMessage = PerformHttpRequest(requestDtoAsString);
        return await ParseResponseMessage(responseMessage);
    }

    private string ParseRequestDto(
        CreateValueRequestDto requestDto
    )
    {
        _logger.LogInformation("Parsing request DTO...");

        var requestDtoAsString = JsonConvert.SerializeObject(requestDto);

        _logger.LogInformation("Request DTO is parsed successfully");

        return requestDtoAsString;
    }

    private HttpResponseMessage PerformHttpRequest(
        string requestDtoAsString
    )
    {
        _logger.LogInformation("Performing web request...");

        var stringContent = new StringContent(
            requestDtoAsString,
            Encoding.UTF8,
            "application/json"
        );

        var httpRequest = new HttpRequestMessage(
            HttpMethod.Post,
            PERSISTANCY_CREATE_URI
        )
        {
            Content = stringContent
        };

        var response = _httpClient.Send(httpRequest);

        _logger.LogInformation("Web request is performed successfully");

        return response;
    }

    private async Task<ValueEntity> ParseResponseMessage(
        HttpResponseMessage responseMessage
    )
    {
        _logger.LogInformation("Parsing response DTO...");
        var responseBody = await responseMessage.Content.ReadAsStringAsync();

        _logger.LogInformation($"Response body: {responseBody}");

        var value = JsonConvert.DeserializeObject<ResponseDto<ValueEntity>>(responseBody);
        _logger.LogInformation("Response DTO is parsed successfully");

        return value.Data;
    }
}
