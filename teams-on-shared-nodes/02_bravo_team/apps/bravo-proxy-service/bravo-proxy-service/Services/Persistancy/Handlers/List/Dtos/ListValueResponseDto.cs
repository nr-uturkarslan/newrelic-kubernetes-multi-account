using bravo_proxy_service.Services.Persistancy.Data;
using Newtonsoft.Json;

namespace bravo_proxy_service.Services.Persistancy.Handlers.List.Dtos;

public class ListValueResponseDto
{
    [JsonProperty("values")]
    public List<ValueEntity> Values { get; set; }
}
