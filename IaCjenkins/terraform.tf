provider "aws" {
  region = "us-east-1" # Cambia a tu región preferida
}

# Crear un grupo de seguridad
resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow inbound access on port 8080"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acceso SSH desde cualquier IP (puedes limitarlo a una IP si lo deseas)
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acceso desde cualquier IP
  }

  # Puedes agregar una regla egress si necesitas acceso de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Todo el tráfico de salida
    cidr_blocks = ["0.0.0.0/0"] # Permitir tráfico de salida a cualquier IP
  }

  tags = {
    Name = "SecurityGroup-Allow-8080"
  }
}

resource "aws_instance" "my_instance" {
  ami             = "ami-0866a3c8686eaeeba"
  instance_type   = "t2.medium"
  security_groups = [aws_security_group.allow_8080.name]
  user_data       = <<EOF
#!/bin/bash
# Actualizar el sistema
echo "Actualizando el sistema..." >> /var/log/user_data.log
sudo apt-get update -y >> /var/log/user_data.log 2>&1
sudo apt-get install -y ca-certificates curl >> /var/log/user_data.log 2>&1

# Agregar la clave de Docker
echo "Agregando clave de Docker..." >> /var/log/user_data.log
sudo install -m 0755 -d /etc/apt/keyrings >> /var/log/user_data.log 2>&1
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc >> /var/log/user_data.log 2>&1
sudo chmod a+r /etc/apt/keyrings/docker.asc >> /var/log/user_data.log 2>&1

# Agregar el repositorio de Docker
echo "Agregando repositorio de Docker..." >> /var/log/user_data.log
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >> /var/log/user_data.log 2>&1

# Actualizar e instalar Docker
echo "Instalando Docker..." >> /var/log/user_data.log
sudo apt-get update -y >> /var/log/user_data.log 2>&1
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> /var/log/user_data.log 2>&1

# Instalar Docker Compose
echo "Instalando Docker Compose..." >> /var/log/user_data.log
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >> /var/log/user_data.log 2>&1
sudo chmod +x /usr/local/bin/docker-compose >> /var/log/user_data.log 2>&1

# Verificar si Docker y Docker Compose están funcionando
echo "Verificando Docker..." >> /var/log/user_data.log
sudo docker run hello-world >> /var/log/user_data.log 2>&1

echo "Verificando Docker Compose..." >> /var/log/user_data.log
docker-compose --version >> /var/log/user_data.log 2>&1

# Ejecutar Jenkins en Docker
echo "Ejecutando Jenkins en Docker..." >> /var/log/user_data.log
sudo docker run -d --name=jenkins -p 8080:8080 jenkins/jenkins >> /var/log/user_data.log 2>&1
sudo usermod -aG docker $USER
EOF
  tags = {
    Name = "InstanciaJenkins"
  }

  key_name = "my-key-pair"
}
