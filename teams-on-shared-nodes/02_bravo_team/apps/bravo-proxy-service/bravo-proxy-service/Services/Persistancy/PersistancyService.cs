using System.Net;
using bravo_proxy_service.Dtos;
using bravo_proxy_service.Services.Persistancy.Handlers.Create;
using bravo_proxy_service.Services.Persistancy.Handlers.Create.Dtos;
using bravo_proxy_service.Services.Persistancy.Handlers.List;
using bravo_proxy_service.Services.Persistancy.Handlers.List.Dtos;

namespace bravo_proxy_service.Services.Persistancy;

public interface IPersistancyService
{
    Task<ResponseDto<CreateValueResponseDto>> Create(
        CreateValueRequestDto requestDto
    );

    Task<ResponseDto<ListValueResponseDto>> List();
}

public class PersistancyService : IPersistancyService
{
    private readonly ILogger<PersistancyService> _logger;

    private readonly ICreateValueHandler _createValueHandler;
    private readonly IListValueHandler _listValueHandler;

    public PersistancyService(
        ILogger<PersistancyService> logger,
        ICreateValueHandler createValueHandler,
        IListValueHandler listValueHandler
    )
    {
        _logger = logger;
        _createValueHandler = createValueHandler;
        _listValueHandler = listValueHandler;
    }

    public async Task<ResponseDto<CreateValueResponseDto>> Create(
        CreateValueRequestDto requestDto
    )
    {
        _logger.LogInformation("Creating value entity ...");

        // Send request to persistancy service.
        var value = await _createValueHandler.Run(requestDto);

        // Create response DTO.
        var responseDto = new ResponseDto<CreateValueResponseDto>
        {
            Message = "Value is created successfully.",
            StatusCode = HttpStatusCode.Created,
            Data = value,
        };

        return responseDto;
    }

    public async Task<ResponseDto<ListValueResponseDto>> List()
    {
        _logger.LogInformation("Retrieving value entities ...");

        // Send request to persistancy service.
        var values = await _listValueHandler.Run();

        // Create response DTO.
        var responseDto = new ResponseDto<ListValueResponseDto>
        {
            Message = "Values are retrieved successfully.",
            StatusCode = HttpStatusCode.OK,
            Data = values,
        };

        return responseDto;
    }
}
