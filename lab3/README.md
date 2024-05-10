# Lab 3

## Polecenie

Proszę zainstalować Spring Petclinic w wersji cloud w Azure przy użyciu usługi AKS Azure Kubernetes Service.

[Repozytorium wersji Spring Petclinic Cloud](https://github.com/spring-petclinic/spring-petclinic-cloud)

### Założenia

1. AKS powinien działać na co najmniej 2 węzłach roboczych (2 nodach) - nie wliczam do tej liczby control plane.
1. Każdy mikroserwis ze zbioru
    - customers-service
    - vets-service
    - visits-service

    powinien działać w co najmniej 2 Pod-ach, każdy Pod dla danego mikroserwisu powinien działać na innym węźle.
3. Bazy danych mogą być uruchomione w Pod-ach. Alternatywnie można skorzystać z [MySQL jako usługi zarządzanej Azure](https://docs.microsoft.com/en-us/azure/mysql/) - do decyzji zespołu.
4. Można pominąć mikroserwisy narzędziowe :
    - admin-server
    - config-server
    - discovery-server
    - Wavefront
5. Podstawowy zakres projektu obejmuje zainstalowanie aplikacji i zademonstrowanie jej działania w Azure. Można zademonstrować osobiście albo nagrywając film-demo - zgodnie z powyższymi założeniami. **10 p.**
6. Zadania dodatkowe:
    - integrację aplikacji z monitoringiem Azure Insights tak żeby zapewnić monitoring stanu mikroserwisów oraz podgląd logów generowanych przez aplikację. **1 p.**
    - konfiguracja klastra AKS przy użyciu skryptów terraformowych **2 p.**
    - konfiguracja pipeline CI/CD, który zapewni budowanie i deployment nowej wersji aplikacji po commicie w githubie przy użyciu [Azure Piplines](https://docs.microsoft.com/pl-pl/azure/devops/pipelines/?view=azure-devops&source=docs) **2 p.**