CREATE SCHEMA Citizen;
GO

CREATE SCHEMA Application;
GO

CREATE TABLE Citizen.Address (
    address_id INT  IDENTITY(1,1) PRIMARY KEY,

    region VARCHAR(50) NOT NULL,
    zone VARCHAR(50),
    sub_city VARCHAR(50),
    woreda VARCHAR(50),
    kebele VARCHAR(50),
    house_number VARCHAR(20)
);

CREATE TABLE Citizen.Information (

	citizen_id INT IDENTITY(1,1) PRIMARY KEY,

	full_name VARCHAR(50) NOT NULL,
	father_name VARCHAR(50) NOT NULL,
	grandfather_name VARCHAR(50) NOT NULL,

	gender VARCHAR(10) NOT NULL,
		CHECK (gender IN ('Male', 'Female')),
	birthdate DATE NOT NULL,
	phone VARCHAR(20) UNIQUE,
	pobox VARCHAR(20) UNIQUE,
	email VARCHAR(50) UNIQUE,



	fingerprint VARBINARY(MAX),
	photo VARBINARY(MAX),
	iris_scan VARBINARY(MAX),

	address_id INT NOT NULL,

	created_date DATETIME DEFAULT GETDATE(),
    updated_date DATETIME,

	FOREIGN KEY (address_id) REFERENCES Citizen.Address(address_id)
);



CREATE TABLE Citizen.Documentary (
	document_id INT  IDENTITY(1,1) PRIMARY KEY,
	document_type VARCHAR(50),
	document_number VARCHAR(50),
	file_attachment VARBINARY(MAX),
	citizen_id  INT NOT NULL,

	FOREIGN KEY (citizen_id) REFERENCES Citizen.Information(citizen_id),
	UNIQUE (document_type, document_number)

);

CREATE TABLE Application.Center(
	center_id INT  IDENTITY(1,1) PRIMARY KEY,
	region VARCHAR(50) NOT NULL,
    zone VARCHAR(50),
    sub_city VARCHAR(50),
    woreda VARCHAR(50),
	center_name VARCHAR(50)
);

CREATE TABLE Application.Machine(
	machine_id INT IDENTITY(1,1) PRIMARY KEY,
	center_id INT NOT NULL,
	status VARCHAR(20) NOT NULL
		DEFAULT 'Active'
		CHECK (status IN ('Active', 'Repair', 'Offline')),
	installed_date DATE NOT NULL,

	FOREIGN KEY (center_id) REFERENCES Application.Center(center_id)
);

CREATE INDEX idx_machine_center_id ON Application.Machine(center_id);

CREATE TABLE Application.Officer(
	officer_id INT IDENTITY(1,1) PRIMARY KEY,
	center_id INT NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	father_name VARCHAR(50) NOT NULL,
	grandfather_name VARCHAR(50) ,
	
	role VARCHAR(20) NOT NULL
		DEFAULT 'Officer'
		CHECK (role IN ('Supervisor', 'Officer')),

	FOREIGN KEY (center_id) REFERENCES Application.Center(center_id)
);

CREATE INDEX idx_officer_center_id ON Application.Officer(center_id);


CREATE TABLE Application.Form(
	application_id INT IDENTITY(1,1) PRIMARY KEY,
	citizen_id INT NOT NULL,
	officer_id INT NOT NULL,
	machine_id INT NOT NULL,
	center_id INT NOT NULL,

	application_type VARCHAR(20) NOT NULL
		DEFAULT 'New'
		CHECK(application_type IN ('New', 'Renewal', 'Replacement')),
		
    application_date DATE NOT NULL DEFAULT GETDATE(),

    status VARCHAR(20) NOT NULL
		DEFAULT 'Pending'
		CHECK(status IN('Pending', 'Approved', 'Rejected', 'Printed')),

	FOREIGN KEY (citizen_id) REFERENCES Citizen.Information(citizen_id),
	FOREIGN KEY (officer_id) REFERENCES Application.Officer(officer_id),
	FOREIGN KEY (machine_id) REFERENCES Application.Machine(machine_id),
	FOREIGN KEY (center_id) REFERENCES Application.Center(center_id)

);

CREATE INDEX idx_form_citizen ON Application.Form(citizen_id);
CREATE INDEX idx_form_officer ON Application.Form(officer_id);
CREATE INDEX idx_form_machine ON Application.Form(machine_id);
CREATE INDEX idx_form_center ON Application.Form(center_id);


CREATE TABLE Application.orderTable(
	order_id INT IDENTITY(1,1) PRIMARY KEY,
	application_id	INT NOT NULL,
	payment_date DATE NOT NULL,
	payment_method VARCHAR(20) NOT NULL,

   
    FIN VARCHAR(20),            
    FAN VARCHAR(20),               

    
    delivery_agent VARCHAR(50),    
    delivery_address VARCHAR(200),
    delivery_date DATE,
    received BIT DEFAULT 0,

	FOREIGN KEY (application_id) REFERENCES Application.Form(application_id)

);

CREATE INDEX idx_orders_application ON Application.orderTable(application_id);


