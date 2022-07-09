using System.Net;
using bravo_proxy_service.Dtos;
using Microsoft.AspNetCore.Mvc;

namespace bravo_proxy_service.Controllers;

[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    private readonly ILogger<HealthController> _logger;

    public HealthController(
        ILogger<HealthController> logger
    )
    {
        _logger = logger;
    }

    [HttpGet(Name = "HealthCheck")]
    public OkObjectResult CheckHealth()
    {
        _logger.LogInformation("OK");

        var responseDto = new ResponseDto<string>
        {
            Message = "OK",
            StatusCode = HttpStatusCode.OK,
        };

        return new OkObjectResult(responseDto);
    }
}

