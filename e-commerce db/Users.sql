CREATE TABLE Users (
    user_id        BIGINT IDENTITY(1,1) PRIMARY KEY,
    email          VARCHAR(255) COLLATE Latin1_General_CI_AI NOT NULL,
    password_hash  VARCHAR(500) NOT NULL,
    password_updated_at DATETIME2 NULL,
    phone          VARCHAR(20),
    created_at     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    is_active      BIT NOT NULL DEFAULT 1,
    deleted_at     DATETIME NULL
);

CREATE INDEX idx_user_email_active
ON Users(email)
WHERE is_active = 1;

CREATE TABLE User_Profiles (
    profile_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id        BIGINT NOT NULL UNIQUE,
    first_name     VARCHAR(100),
    last_name      VARCHAR(100),
    date_of_birth  DATE,
    avatar_url     VARCHAR(255),
    CONSTRAINT fk_user_profiles_user
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
);


CREATE TABLE Addresses (
    address_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id        BIGINT NOT NULL,
    address_type   VARCHAR(20)
        CHECK (address_type IN ('home','work','billing','shipping')),
    street         VARCHAR(255),
    city           VARCHAR(100),
    state          VARCHAR(100),
    postal_code    VARCHAR(20),
    country        VARCHAR(100),
    CONSTRAINT fk_addresses_user
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
);



CREATE INDEX idx_addresses_user
ON Addresses(user_id);

CREATE TABLE Session (
    session_id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id        BIGINT NOT NULL,
    token          VARBINARY(64) NOT NULL UNIQUE,
    expires_at     DATETIME NOT NULL,
    revoked_at     DATETIME NULL,
    created_at     DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT fk_sessions_user
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_session_token ON Session(token);
CREATE INDEX idx_session_user ON Session(user_id);
