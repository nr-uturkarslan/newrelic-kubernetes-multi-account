using bravo_proxy_service.Services.Persistancy;
using bravo_proxy_service.Services.Persistancy.Dtos;
using Microsoft.AspNetCore.Mvc;

namespace bravo_proxy_service.Controllers;

[ApiController]
[Route("[controller]")]
public class PersistancyController
{
    private readonly ILogger<PersistancyController> _logger;
    private readonly IPersistancyService _persistancyService;

    public PersistancyController(
        ILogger<PersistancyController> logger,
        IPersistancyService persistancyService
    )
    {
        _logger = logger;
        _persistancyService = persistancyService;
    }

    [HttpPost(Name = "CreateValue")]
    [Route("create")]
    public IActionResult Create(
        [FromBody] CreateValueRequestDto requestDto
    )
    {
        _logger.LogInformation("CreateValue endpoint is triggered...");

        var responseDto = _persistancyService.Create(requestDto);

        return new OkObjectResult(responseDto);
    }
}
