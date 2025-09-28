# Homeserver Talos Infrastructure

Infrastructure as Code para el cluster Kubernetes homeserver usando Talos OS, siguiendo el patrón del [tutorial de shirwalab](https://shirwalab.net/posts/kubernetes-homelab-part1/).

## Arquitectura

- **Hypervisor**: KVM/libvirt en servidor remoto (javi@192.168.1.10)
- **OS**: Talos Linux v1.11.2
- **Orchestration**: Terraform con módulos
- **Networking**: Red privada 10.0.100.0/24 en modo route

## Estructura del Proyecto

```
tf_homeserver/
├── modules/talos/          # Módulo Talos reutilizable
│   ├── files/              # Templates de configuración
│   ├── infrastructure.tf   # Recursos de infraestructura
│   ├── virtual-machines.tf # Definición de VMs
│   ├── talos.tf           # Configuración de Talos
│   └── ...
├── envs/                   # Configuraciones por entorno
│   └── homeserver.tfvars  # Variables del entorno homeserver
├── main.tf                # Configuración principal
├── variables.tf           # Variables globales
├── providers.tf           # Configuración de providers
├── outputs.tf             # Outputs del proyecto
└── Makefile              # Comandos automatizados
```

## Configuración Inicial

1. **Verificar conectividad SSH**:
   ```bash
   ssh javi@192.168.1.10 'virsh list --all'
   ```

2. **Inicializar Terraform**:
   ```bash
   make init ENVNAME=homeserver
   ```

3. **Validar configuración**:
   ```bash
   make validate ENVNAME=homeserver
   make fmt
   ```

## Despliegue

### Planificar cambios
```bash
make plan ENVNAME=homeserver
```

### Aplicar infraestructura
```bash
make apply ENVNAME=homeserver
```

### Aplicar automáticamente (sin confirmación)
```bash
make apply-auto ENVNAME=homeserver
```

## Gestión del Cluster

### Obtener kubeconfig
```bash
# Ver contenido
make show-kubeconfig ENVNAME=homeserver

# Guardar en ~/.kube/config
make save-kubeconfig ENVNAME=homeserver
```

### Ver estado
```bash
make output ENVNAME=homeserver
```

### Acceso a los nodos
```bash
# Configuración del cliente Talos
terraform output -raw client_configuration > ~/.talos/config

# Listar nodos
talosctl nodes

# Acceso a un nodo específico
talosctl -n 10.0.100.11 version
```

## Escalado

### Añadir un worker
Editar `envs/homeserver.tfvars`:

```hcl
nodes = {
  "talos-ctrl-1" = { ... }
  "talos-work-1" = { ... }
  "talos-work-2" = {  # NUEVO NODO
    machine_type = "worker"
    ip           = "10.0.100.13"
    mac_address  = "52:54:00:12:34:13"
    cpu          = 2
    memory       = 3072
    disk_size    = 21474836480
  }
}
```

Aplicar cambios:
```bash
make plan ENVNAME=homeserver
make apply ENVNAME=homeserver
```

## Configuración de Red

- **CIDR del cluster**: 10.0.100.0/24
- **Gateway**: 10.0.100.1
- **Control plane**: 10.0.100.11
- **Workers**: 10.0.100.12+
- **DNS**: 1.1.1.1, 8.8.8.8

## Troubleshooting

### Recrear VMs problemáticas
```bash
make taint-vms ENVNAME=homeserver
make apply ENVNAME=homeserver
```

### Limpiar estado
```bash
make destroy ENVNAME=homeserver
make clean
```

### Ver dependencias
```bash
make graph ENVNAME=homeserver
```

## Comandos Útiles

```bash
# Ayuda
make help

# Formatear código
make fmt

# Consola interactiva
make console ENVNAME=homeserver

# Ver outputs
make output ENVNAME=homeserver
```

## Configuración Avanzada

### Personalizar schematic de Talos
Editar `modules/talos/files/schematic.yaml` para añadir extensiones del sistema.

### Variables por entorno
Crear nuevos archivos en `envs/` para diferentes entornos:
- `envs/production.tfvars`
- `envs/staging.tfvars`

## Recursos

- [Tutorial original - shirwalab](https://shirwalab.net/posts/kubernetes-homelab-part1/)
- [Documentación Talos](https://www.talos.dev/docs/)
- [Provider Terraform libvirt](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs)
- [Provider Terraform Talos](https://registry.terraform.io/providers/siderolabs/talos/latest/docs)