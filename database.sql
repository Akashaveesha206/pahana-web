-- Bookshop Database Dump
-- MySQL Database for Bookshop Application
-- Generated for MySQL 8.0+

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS bookshop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bookshop;

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS feedbacks;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS books;

-- Users table
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(120) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_status (status)
);

-- User roles table
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id, role),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
);

-- Books table
CREATE TABLE books (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image VARCHAR(500),
    category VARCHAR(50) NOT NULL,
    stock INT DEFAULT 0,
    total_sold INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_title (title),
    INDEX idx_author (author),
    INDEX idx_stock (stock),
    INDEX idx_total_sold (total_sold)
);

-- Orders table
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    user_email VARCHAR(100),
    order_number VARCHAR(50) UNIQUE,
    customer_name VARCHAR(100),
    total DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    shipping_first_name VARCHAR(50),
    shipping_last_name VARCHAR(50),
    shipping_email VARCHAR(100),
    shipping_phone VARCHAR(20),
    shipping_address VARCHAR(255),
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),
    shipping_zip_code VARCHAR(20),
    shipping_country VARCHAR(50),
    payment_card_number VARCHAR(20),
    payment_name_on_card VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_user_email (user_email),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);

-- Order items table
CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    book_id BIGINT,
    title VARCHAR(255),
    author VARCHAR(100),
    price DECIMAL(10,2),
    quantity INT,
    image VARCHAR(500),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_book_id (book_id)
);

-- Feedbacks table
CREATE TABLE feedbacks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    customer_name VARCHAR(100) NOT NULL,
    comment TEXT NOT NULL,
    rating INT NOT NULL,
    feedback_type VARCHAR(20),
    book_id BIGINT,
    is_approved BOOLEAN DEFAULT FALSE,
    is_visible BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_book_id (book_id),
    INDEX idx_is_approved (is_approved),
    INDEX idx_is_visible (is_visible),
    INDEX idx_created_at (created_at)
);

-- Insert default admin user (password: admin123)
INSERT INTO users (name, email, password, status, created_at, updated_at) 
VALUES ('Admin', 'admin@bookshop.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'active', NOW(), NOW());

-- Insert admin role
INSERT INTO user_roles (user_id, role) 
SELECT id, 'ROLE_ADMIN' FROM users WHERE email = 'admin@bookshop.com';

-- Insert sample books
INSERT INTO books (title, author, description, price, category, stock, created_at, updated_at) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'A story of the fabulously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan. Set in the Jazz Age on Long Island, the novel depicts first-person narrator Nick Carraway''s interactions with mysterious millionaire Jay Gatsby and Gatsby''s obsession to reunite with his former lover, Daisy Buchanan.', 12.99, 'Fiction', 50, NOW(), NOW()),
('To Kill a Mockingbird', 'Harper Lee', 'The story of young Scout Finch and her father Atticus in a racially divided Alabama town. Through the eyes of Scout, a six-year-old girl, the novel explores themes of racial injustice, loss of innocence, and the coexistence of good and evil.', 11.99, 'Fiction', 45, NOW(), NOW()),
('1984', 'George Orwell', 'A dystopian novel about totalitarianism and surveillance society. The story follows the life of Winston Smith, a low-ranking member of the ruling Party in London, who is frustrated by the omnipresent eyes of the party, and its ominous ruler Big Brother.', 10.99, 'Fiction', 40, NOW(), NOW()),
('Pride and Prejudice', 'Jane Austen', 'The story of Elizabeth Bennet and Mr. Darcy in Georgian-era England. The novel explores themes of love, marriage, class, and reputation through the lens of Elizabeth''s journey to find true love.', 9.99, 'Romance', 35, NOW(), NOW()),
('The Hobbit', 'J.R.R. Tolkien', 'The adventure of Bilbo Baggins, a hobbit who embarks on a quest with a group of dwarves to reclaim their mountain home from a dragon. The novel explores themes of heroism, friendship, and the value of home.', 14.99, 'Fantasy', 60, NOW(), NOW()),
('The Catcher in the Rye', 'J.D. Salinger', 'The story of Holden Caulfield, a teenager who wanders around New York City after being expelled from prep school. The novel explores themes of alienation, loss of innocence, and the phoniness of the adult world.', 13.99, 'Fiction', 30, NOW(), NOW()),
('Lord of the Flies', 'William Golding', 'A group of British boys stranded on an uninhabited island must govern themselves, with disastrous results. The novel explores themes of human nature, civilization versus savagery, and the loss of innocence.', 11.99, 'Fiction', 25, NOW(), NOW()),
('The Alchemist', 'Paulo Coelho', 'The story of Santiago, an Andalusian shepherd boy who dreams of finding a worldly treasure. His journey teaches him to listen to his heart and follow his dreams.', 8.99, 'Self-Help', 40, NOW(), NOW()),
('The Little Prince', 'Antoine de Saint-Exupéry', 'A poetic tale about a young prince who visits various planets in space, including Earth, and addresses themes of loneliness, friendship, love, and loss.', 7.99, 'Children', 55, NOW(), NOW()),
('The Art of War', 'Sun Tzu', 'An ancient Chinese text on military strategy and tactics. The work contains a detailed explanation and analysis of the Chinese military.', 6.99, 'Non-Fiction', 20, NOW(), NOW());

-- Insert sample feedback
INSERT INTO feedbacks (user_id, customer_name, comment, rating, feedback_type, is_approved, created_at, updated_at) VALUES
(1, 'John Doe', 'Great book selection and fast delivery! The website is easy to navigate and the checkout process was smooth.', 5, 'service', TRUE, NOW(), NOW()),
(1, 'Jane Smith', 'The Great Gatsby is a masterpiece. Beautifully written and a must-read for anyone interested in American literature.', 5, 'book', TRUE, NOW(), NOW()),
(1, 'Mike Johnson', 'Excellent customer service and the books arrived in perfect condition. Will definitely shop here again!', 4, 'service', TRUE, NOW(), NOW());

-- Create a test user (password: user123)
INSERT INTO users (name, email, password, status, created_at, updated_at) 
VALUES ('Test User', 'user@bookshop.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'active', NOW(), NOW());

-- Insert user role for test user
INSERT INTO user_roles (user_id, role) 
SELECT id, 'ROLE_USER' FROM users WHERE email = 'user@bookshop.com';

-- Show database information
SELECT 'Database setup completed successfully!' as status;
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_books FROM books;
SELECT COUNT(*) as total_feedbacks FROM feedbacks; 