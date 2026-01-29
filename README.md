# proyecto_mean_terraform_2D

Para ejecutar el proyecto de manera correcta usando terraform sigue los siguientes pasos:

1. Levantar terraform mongodb
desde la ruta de terraform mongodb usa los siguientes comandos

    ```bash
    terraform init
    terraform plan -out tfplan
    terraform apply
    ```
    IMPORTANTE 
    Al crearse la instancia copia el valor del output "mongodb_public_ip" ya que servira para establecer la comunicacion con el backend de expess

2. Levantar terraform backend
desde la ruta de terraform backend usa los siguientes comandos

    ```bash
    terraform init
    terraform plan -out tfplan
    terraform apply -var="mongodb_public_ip=<mongo_public_ip>"
    ```
    IMPORTANTE 
    Al crearse la instancia copia el valor del output "application_url" ya que servira para establecer la comunicacion con el frontend
3. Levantar terraform frontend
desde la ruta de terraform frontend usa los siguientes comandos

    ```bash
    terraform init
    terraform plan -out tfplan
    terraform apply -var="backend_api_url=<application_url>"
    ```
    IMPORTANTE 
    Al crearse la instancia el valor de "application_url" será la direccion ip publica de la app