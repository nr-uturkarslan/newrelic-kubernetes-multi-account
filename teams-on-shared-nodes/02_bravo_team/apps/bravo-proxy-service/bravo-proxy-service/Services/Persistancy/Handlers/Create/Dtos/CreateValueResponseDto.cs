using bravo_proxy_service.Services.Persistancy.Data;
using Newtonsoft.Json;

namespace bravo_proxy_service.Services.Persistancy.Handlers.Create.Dtos;

public class CreateValueResponseDto
{
    [JsonProperty("value")]
    public ValueEntity Value { get; set; }
}
