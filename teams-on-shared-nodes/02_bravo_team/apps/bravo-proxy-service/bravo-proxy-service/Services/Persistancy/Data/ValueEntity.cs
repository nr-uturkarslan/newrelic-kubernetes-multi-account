using System.Text.Json.Serialization;

namespace bravo_proxy_service.Services.Persistancy.Data;

public class ValueEntity
{
    [JsonPropertyName("id")]
    public string Id { get; set; }

    [JsonPropertyName("value")]
    public string Value { get; set; }

    [JsonPropertyName("tag")]
    public string Tag { get; set; }
}

