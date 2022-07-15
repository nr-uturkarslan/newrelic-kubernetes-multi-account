using bravo_proxy_service.Services.Persistancy;
using bravo_proxy_service.Services.Persistancy.Handlers.Create.Dtos;
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
    public async Task<IActionResult> Create(
        [FromBody] CreateValueRequestDto requestDto
    )
    {
        _logger.LogInformation("CreateValue endpoint is triggered...");

        var responseDto = await _persistancyService.Create(requestDto);

        return new CreatedResult($"{responseDto.Data.Value.Id}", responseDto);
    }

    [HttpGet(Name = "ListValues")]
    [Route("list")]
    public async Task<IActionResult> List()
    {
        _logger.LogInformation("ListValues endpoint is triggered...");

        var responseDto = await _persistancyService.List();

        return new OkObjectResult(responseDto);
    }

    [HttpDelete(Name = "DeleteValue")]
    [Route("delete")]
    public async Task<IActionResult> Delete(
        [FromQuery] string id
    )
    {
        _logger.LogInformation("DeleteValue endpoint is triggered...");

        var responseDto = _persistancyService.Delete(id);

        return new OkObjectResult(responseDto);
    }
}
