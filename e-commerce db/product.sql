CREATE TABLE Product_Category (
    category_id INT IDENTITY PRIMARY KEY,
    parent_category_id INT NULL,
    category_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (parent_category_id)                    -- self-joint allows us to have hierarchy of categories 
		REFERENCES Product_Category(category_id)		-- and infinite catagories
);


CREATE TABLE Product(
	product_id INT IDENTITY(1,1) PRIMARY KEY,
	category_id INT FOREIGN KEY REFERENCES Product_Category(category_id),
	name VARCHAR(100) NOT NULL,
	description VARCHAR(500),
	product_image_url VARCHAR(255) NOT NULL,

	--STATUS & AUDIT COLUMN

	is_active BIT DEFAULT 1,
	created_at DATETIME DEFAULT GETDATE(),
	updated_at DATETIME


);

CREATE TABLE Product_Item(
	product_item_id INT IDENTITY(1,1) PRIMARY KEY,
	product_id INT FOREIGN KEY REFERENCES Product(product_id),
	sku VARCHAR(50) UNIQUE NOT NULL,
	qty_in_stock INT NOT NULL CHECK (qty_in_stock >= 0),
	low_stock_threshold INT DEFAULT 5,
	product_image_url VARCHAR(255),
	price DECIMAL(10,2) NOT NULL,

	--STATUS & AUDIT COLUMN

	is_active BIT DEFAULT 1,
	created_at DATETIME DEFAULT GETDATE(),
	updated_at DATETIME
);

CREATE TABLE Variation (
    variation_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,                                                -- naming like color, size or storage/RAM (for electornics)
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
	CONSTRAINT uq_product_variation UNIQUE (product_id, name)
);

CREATE TABLE Variation_Option (
	variation_option_id INT IDENTITY(1,1) PRIMARY KEY,
	variation_id INT FOREIGN KEY REFERENCES Variation(variation_id),
	value VARCHAR(20) NOT NULL,                                              -- like for size - xl, l, s...   for color gray,blue...
	CONSTRAINT uq_variation_option UNIQUE (variation_id, value)
);

CREATE TABLE Promotion(
	promotion_id INT IDENTITY(1,1) PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(500) ,
	discount_type VARCHAR(10) CHECK (discount_type IN ('PERCENT', 'FIXED')),
	discount_value DECIMAL(10,2),
	start_date DATE,
	end_date DATE,
	CONSTRAINT chk_promotion_dates CHECK (end_date IS NULL OR end_date >= start_date),

	--STATUS & AUDIT COLUMN

	is_active BIT DEFAULT 1,
	created_at DATETIME DEFAULT GETDATE(),
	updated_at DATETIME
);

CREATE TABLE Promotion_Category (
    category_id INT NOT NULL,
    promotion_id INT NOT NULL,
    PRIMARY KEY (category_id, promotion_id),
    FOREIGN KEY (category_id) REFERENCES Product_Category(category_id),
    FOREIGN KEY (promotion_id) REFERENCES Promotion(promotion_id)
);


CREATE TABLE Product_Configuration (
    product_item_id INT NOT NULL,
    variation_option_id INT NOT NULL,
    PRIMARY KEY (product_item_id, variation_option_id),
    FOREIGN KEY (product_item_id) REFERENCES Product_Item(product_item_id),
    FOREIGN KEY (variation_option_id) REFERENCES Variation_Option(variation_option_id)
);

CREATE TABLE Inventory_Transaction (
    transaction_id INT IDENTITY PRIMARY KEY,
    product_item_id INT NOT NULL,
    quantity_change INT NOT NULL,
    transaction_type VARCHAR(20) 
		CHECK (transaction_type IN ('SALE', 'RESTOCK', 'RETURN')), 
    transaction_date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (product_item_id) REFERENCES Product_Item(product_item_id)
);

CREATE INDEX idx_product_category ON Product(category_id);
CREATE INDEX idx_productitem_product ON Product_Item(product_id);
CREATE INDEX idx_variation_product ON Variation(product_id);


--  category -> product -> variation -> variation_option -> product_item (sku)