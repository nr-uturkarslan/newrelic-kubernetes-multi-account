using System;
using bravo_proxy_service.Dtos;
using bravo_proxy_service.Services.Persistancy.Handlers.Delete.Dtos;
using Newtonsoft.Json;

namespace bravo_proxy_service.Services.Persistancy.Handlers.Delete
{
    public interface IDeleteValueHandler
    {
        void Run(
            string id
        );
    }

    public class DeleteValueHandler : IDeleteValueHandler
    {
        private const string PERSISTANCY_DELETE_URI =
        "http://persistancy.bravo.svc.cluster.local:8080/persistancy/delete";

        private readonly ILogger<IDeleteValueHandler> _logger;

        private readonly HttpClient _httpClient;

        public DeleteValueHandler(
            ILogger<IDeleteValueHandler> logger,
            IHttpClientFactory factory
        )
        {
            _logger = logger;

            _httpClient = factory.CreateClient();
        }

        public void Run(
            string id
        )
        {
            PerformHttpRequest(id);
        }

        private HttpResponseMessage PerformHttpRequest(
            string id
        )
        {
            _logger.LogInformation("Performing web request...");

            var httpRequest = new HttpRequestMessage(
                HttpMethod.Delete,
                $"{PERSISTANCY_DELETE_URI}?id={id}"
            );

            var response = _httpClient.Send(httpRequest);

            _logger.LogInformation("Web request is performed successfully");

            return response;
        }
    }
}

