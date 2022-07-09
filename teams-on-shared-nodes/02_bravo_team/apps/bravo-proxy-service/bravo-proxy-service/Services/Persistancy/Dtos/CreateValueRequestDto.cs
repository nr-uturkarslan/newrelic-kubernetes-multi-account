using Newtonsoft.Json;

namespace bravo_proxy_service.Services.Persistancy.Dtos;

public class CreateValueRequestDto
{
    [JsonProperty("value")]
    public string? Value { get; set; }

    [JsonProperty("tag")]
    public string? Tag { get; set; }
}
