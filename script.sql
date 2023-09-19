DROP DATABASE IF EXISTS tiendas; 
CREATE DATABASE tiendas; 
USE tiendas;

-- Crear tabla Catálogo General
CREATE TABLE CatalogoGeneral (
  Codigo INT PRIMARY KEY,
  NombreProducto VARCHAR(255),
  Costo DECIMAL(10, 2),
  Precio DECIMAL(10, 2),
  Existencias INT
);

-- Crear tabla Catálogo por Tienda
CREATE TABLE CatalogoPorTienda (
  Codigo INT PRIMARY KEY,
  NombreProducto VARCHAR(255),
  Costo DECIMAL(10, 2),
  Precio DECIMAL(10, 2),
  Existencias INT
);

-- Crear tabla Catálogo Dañados
CREATE TABLE CatalogoDanados (
  Codigo INT PRIMARY KEY,
  Producto VARCHAR(255),
  Cantidad INT,
  Costo DECIMAL(10, 2),
  Fecha DATE,
  NumeroTienda INT
);

-- Crear tabla Listado de Tiendas
CREATE TABLE ListadoTiendas (
  Tienda INT PRIMARY KEY,
  Direccion VARCHAR(255),
  NombreTienda VARCHAR(255)
);



-- Crear tabla Tienda
CREATE TABLE Tienda (
  NumeroTienda INT PRIMARY KEY,
  TipoTienda ENUM('Tienda_Normal', 'Tienda_Supervisada'),
  CatalogoTienda INT,
  ListadoPedidos INT,
  LimiteProductos INT,
  FOREIGN KEY (CatalogoTienda) REFERENCES CatalogoPorTienda(Codigo)
 );

-- Crear tabla ListadoGeneralPedidos
CREATE TABLE ListadoGeneralPedidos (
  NumeroPedido INT PRIMARY KEY,
  Tienda INT,
  FOREIGN KEY (Tienda) REFERENCES Tienda(NumeroTienda)
);


ALTER TABLE Tienda ADD CONSTRAINT fk FOREIGN KEY (ListadoPedidos) REFERENCES ListadoGeneralPedidos(NumeroPedido);


-- Crear tabla AutorizacionPedido
CREATE TABLE AutorizacionPedido (
  CodigoPedido INT PRIMARY KEY,
  ListadoGeneralPedidos INT,
  EstadoAutorizacion ENUM('Pedido_Enviado', 'Pedido_Recibido', 'Pedido_Rechazado'),
  FOREIGN KEY (ListadoGeneralPedidos) REFERENCES ListadoGeneralPedidos(NumeroPedido)
);




-- Crear tabla DetallePedido
CREATE TABLE DetallePedido (
  CodigoPedido INT,
  Producto VARCHAR(255),
  CodigoProducto INT,
  Cantidad INT,
  PRIMARY KEY (CodigoPedido, Producto),
  FOREIGN KEY (CodigoPedido) REFERENCES ListadoGeneralPedidos(NumeroPedido)
);



-- Crear tabla ListadoEnvios
CREATE TABLE ListadoEnvios (
  NumeroEnvio INT PRIMARY KEY,
  ListadoGeneralPedidos INT,
  Fecha DATE,
  DetalleEnvio INT,
  Estado ENUM('Pedido_Enviado', 'Pedido_Recibido', 'Pedido_Rechazado'),
  FOREIGN KEY (ListadoGeneralPedidos) REFERENCES ListadoGeneralPedidos(NumeroPedido)
);

-- Crear tabla BodegaCentral
CREATE TABLE BodegaCentral (
  CodigoBodega INT PRIMARY KEY,
  CatalogoGeneral INT,
  CatalogoDanados INT,
  ListadoGeneralPedidos INT,
  ListadoEnvios INT,
  ReporteIncidencia INT,
  ReporteDevolucion INT,
  FOREIGN KEY (CatalogoGeneral) REFERENCES CatalogoGeneral(Codigo),
  FOREIGN KEY (CatalogoDanados) REFERENCES CatalogoDanados(Codigo),
  FOREIGN KEY (ListadoGeneralPedidos) REFERENCES ListadoGeneralPedidos(NumeroPedido),
  FOREIGN KEY (ListadoEnvios) REFERENCES ListadoEnvios(NumeroEnvio)
 );




-- Crear tabla DetalleEnvio
CREATE TABLE DetalleEnvio (
  NumeroEnvio INT,
  Codigo INT,
  Producto VARCHAR(255),
  Cantidad INT,
  PRIMARY KEY (NumeroEnvio, Codigo),
  FOREIGN KEY (NumeroEnvio) REFERENCES ListadoEnvios(NumeroEnvio)
);

-- Crear tabla ReportePedido
CREATE TABLE ReportePedido (
  NumeroReporte INT PRIMARY KEY,
  ListadoPedidos INT,
  EstadoPedido ENUM('Pedido_Enviado', 'Pedido_Recibido', 'Pedido_Rechazado'),
  MotivoRechazo VARCHAR(255),
  FechaRecepcion DATE,
  FechaEntrega DATE,
  FOREIGN KEY (ListadoPedidos) REFERENCES ListadoGeneralPedidos(NumeroPedido)
);

-- Crear tabla UsuariosTienda
CREATE TABLE UsuariosTienda (
  ID INT PRIMARY KEY,
  Nombres VARCHAR(255),
  Apellidos VARCHAR(255),
  Puesto VARCHAR(255),
  Tienda INT,
  Estado ENUM('Usuario_Activo', 'Usuario_Inactivo'),
  CantidadPedidos INT,
  FOREIGN KEY (Tienda) REFERENCES Tienda(NumeroTienda)
);

-- Crear tabla UsuariosBodega
CREATE TABLE UsuariosBodega (
  ID INT PRIMARY KEY,
  Nombres VARCHAR(255),
  Apellidos VARCHAR(255),
  TiendasAsignadas VARCHAR(255),
  Estado ENUM('Usuario_Activo', 'Usuario_Inactivo'),
  CantidadEnvios INT
);

-- Crear tabla RecibirEnvio
CREATE TABLE RecibirEnvio (
  NumeroEnvio INT,
  IDUsuario INT,
  Tienda INT,
  Fecha DATE,
  EstadoEnvio ENUM('Pedido_Enviado', 'Pedido_Recibido', 'Pedido_Rechazado'),
  PRIMARY KEY (NumeroEnvio, IDUsuario),
  FOREIGN KEY (NumeroEnvio) REFERENCES ListadoEnvios(NumeroEnvio),
  FOREIGN KEY (IDUsuario) REFERENCES UsuariosBodega(ID),
  FOREIGN KEY (Tienda) REFERENCES Tienda(NumeroTienda)
);

-- Crear tabla Incidencia
CREATE TABLE Incidencia (
  CodigoIncidencia INT PRIMARY KEY,
  ProductoRecibido VARCHAR(255),
  CodigoProducto INT,
  CantidadProducto INT,
  Fecha DATE,
  Tienda INT,
  MotivoIncidencia VARCHAR(255),
  FOREIGN KEY (Tienda) REFERENCES Tienda(NumeroTienda)
);

-- Crear tabla ReporteIncidencias
CREATE TABLE ReporteIncidencias (
  CodigoIncidencia INT,
  EstadoIncidencia ENUM('Pedido_Enviado', 'Pedido_Recibido', 'Pedido_Rechazado'),
  MotivoRechazo VARCHAR(255),
  NumeroReporte INT,
  FechaRecepcion DATE,
  FechaFinalizacion DATE,
  PRIMARY KEY (CodigoIncidencia, NumeroReporte),
  FOREIGN KEY (NumeroReporte) REFERENCES ReportePedido(NumeroReporte)
);

ALTER TABLE BodegaCentral ADD CONSTRAINT   FOREIGN KEY (ReporteIncidencia) REFERENCES ReporteIncidencias(CodigoIncidencia);


-- Crear tabla Devolucion
CREATE TABLE Devolucion (
  NumeroDevolucion INT PRIMARY KEY,
  ReporteIncidencias INT,
  Producto VARCHAR(255),
  CodigoProducto INT,
  Cantidad INT,
  Fecha DATE,
  FOREIGN KEY (ReporteIncidencias) REFERENCES ReporteIncidencias(CodigoIncidencia)
);

-- Crear tabla ReporteDevolucion
CREATE TABLE ReporteDevolucion (
  NumeroReporte INT PRIMARY KEY,
  Devolucion INT,
  FechaSolicitud DATE,
  EtapaDevolucion ENUM('Solicitud_Devolución', 'Devolución_Aprobada', 'Devolución_Rechazada', 'Envío_Devolución', 'Devuelto'),
  FechaDevolucion DATE,
  FOREIGN KEY (Devolucion) REFERENCES Devolucion(NumeroDevolucion)
);

ALTER TABLE BodegaCentral ADD CONSTRAINT    FOREIGN KEY (ReporteDevolucion) REFERENCES ReporteDevolucion(NumeroReporte);

-- Crear tabla ReporteCompraProductos
CREATE TABLE ReporteCompraProductos (
  NumeroCompra INT PRIMARY KEY,
  Fecha DATE,
  Proveedor VARCHAR(255),
  DetalleCompraProductos INT
);

-- Crear tabla DetalleCompraProductos
CREATE TABLE DetalleCompraProductos (
  Producto VARCHAR(255),
  CodigoProducto INT,
  Cantidad INT,
  Precio DECIMAL(10, 2),
  PRIMARY KEY (Producto, CodigoProducto),
  FOREIGN KEY (CodigoProducto) REFERENCES ReporteCompraProductos(NumeroCompra)
);

-- Crear tabla ListadoProveedores
CREATE TABLE ListadoProveedores (
  ID INT PRIMARY KEY,
  Nombre VARCHAR(255),
  Estado ENUM('Proveedor_Activo', 'Proveedor_Apartado')
);

-- Crear tabla Supervisores
CREATE TABLE Supervisores (
  ID INT PRIMARY KEY,
  Nombres VARCHAR(255),
  Apellidos VARCHAR(255),
  Estado ENUM('Usuario_Activo', 'Usuario_Inactivo'),
  ListadoGeneralPedidos INT,
  FOREIGN KEY (ListadoGeneralPedidos) REFERENCES ListadoGeneralPedidos(NumeroPedido)
);

-- Crear tabla Administradores
CREATE TABLE Administradores (
  ID INT PRIMARY KEY,
  Nombres VARCHAR(255),
  Apellidos VARCHAR(255),
  CatalogoGeneral INT,
  ListadoProveedores INT,
  UsuariosTienda INT,
  UsuariosBodega INT,
  Supervisores INT,
  ListadoTiendas INT,
  ListadoGeneralPedidos INT,
  FOREIGN KEY (CatalogoGeneral) REFERENCES CatalogoGeneral(Codigo),
  FOREIGN KEY (ListadoProveedores) REFERENCES ListadoProveedores(ID),
  FOREIGN KEY (UsuariosTienda) REFERENCES UsuariosTienda(ID),
  FOREIGN KEY (UsuariosBodega) REFERENCES UsuariosBodega(ID),
  FOREIGN KEY (Supervisores) REFERENCES Supervisores(ID),
  FOREIGN KEY (ListadoTiendas) REFERENCES ListadoTiendas(Tienda),
  FOREIGN KEY (ListadoGeneralPedidos) REFERENCES ListadoGeneralPedidos(NumeroPedido)
);