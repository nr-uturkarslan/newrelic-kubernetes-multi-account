using System.Text;
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
        try
        {
            var responseMessage = await PerformHttpRequest(requestDto);
            return await ParseResponseMessage(responseMessage);
        }
        catch (Exception e)
        {
            _logger.LogError(e.Message);
            return null;
        }
    }

    private async Task<HttpResponseMessage> PerformHttpRequest(
        CreateValueRequestDto requestDto
    )
    {
        _logger.LogInformation("Parsing request DTO...");

        var stringContent = new StringContent(
            JsonConvert.SerializeObject(requestDto),
            Encoding.UTF8,
            "application/json"
        );

        _logger.LogInformation("Request DTO is parsed successfully");

        return await _httpClient.PostAsync(
            PERSISTANCY_CREATE_URI, stringContent);
    }

    private async Task<ValueEntity> ParseResponseMessage(
        HttpResponseMessage responseMessage
    )
    {
        _logger.LogInformation("Parsing response DTO...");
        var responseBody = await responseMessage.Content.ReadAsStringAsync();

        var value = JsonConvert.DeserializeObject<ValueEntity>(responseBody);
        _logger.LogInformation("Response DTO is parsed successfully");

        return value;
    }
}
