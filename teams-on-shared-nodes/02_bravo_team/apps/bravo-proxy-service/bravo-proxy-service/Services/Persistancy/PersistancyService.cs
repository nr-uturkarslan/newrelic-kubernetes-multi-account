using System.Net;
using bravo_proxy_service.Dtos;
using bravo_proxy_service.Services.Persistancy.Data;
using bravo_proxy_service.Services.Persistancy.Dtos;
using bravo_proxy_service.Services.Persistancy.Handlers;

namespace bravo_proxy_service.Services.Persistancy;

public interface IPersistancyService
{
    Task<ResponseDto<ValueEntity>> Create(
        CreateValueRequestDto requestDto
    );
}

public class PersistancyService : IPersistancyService
{
    private readonly ILogger<PersistancyService> _logger;

    private readonly ICreateValueHandler _createValueHandler;

    public PersistancyService(
        ILogger<PersistancyService> logger,
        ICreateValueHandler createValueHandler
    )
    {
        _logger = logger;
        _createValueHandler = createValueHandler;
    }

    public async Task<ResponseDto<ValueEntity>> Create(
        CreateValueRequestDto requestDto
    )
    {
        _logger.LogInformation("Creating value entity ...");

        // Send request to persistancy service.
        var value = await _createValueHandler.Run(requestDto);

        // Create response DTO.
        var responseDto = new ResponseDto<ValueEntity>
        {
            Message = "OK",
            StatusCode = HttpStatusCode.OK,
            Data = value,
        };

        return responseDto;
    }
}
