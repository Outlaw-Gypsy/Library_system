USE library_system_management;
SHOW TABLES;

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE 
FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee with emp_id = 'E101'
SELECT e.emp_id, emp_name, position, issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn
FROM issued_status AS i
JOIN employees AS e
	ON i.issued_emp_id = e.emp_id
WHERE e.emp_id = 'E101';

-- Task 5:List Members Who Have Issued More Than One Book 
SELECT member_id, member_name, COUNT(*) AS no_books_issued
FROM issued_status AS i
JOIN members AS m
	ON i.issued_member_id = m.member_id
GROUP BY member_id, member_name
HAVING no_books_issued > 1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

SELECT *
FROM book_issued_cnt;

-- Task 7: Retrieve All Books in a Specific Category:
SELECT DISTINCT(category)
FROM books;

SELECT isbn, book_title, category
FROM books
WHERE category = 'horror';

-- Task 8: Find Total Rental Income by Category:
SELECT category, SUM(rental_price) AS total_rental, COUNT(category)
FROM books
GROUP BY category
ORDER BY total_rental DESC;

-- Task 9: List Members Who Registered in the Last 180 Days:
SELECT * 
FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT e.emp_id, e.emp_name, e.position, manager_id, e2.emp_name AS manager, b.*
FROM branch AS b
JOIN employees AS e
	ON b.branch_id = e.branch_id
JOIN employees AS e2
	ON b.manager_id = e2.emp_id;
    
-- Task 11: Create a Table of Books with Rental Price Above a Certain Threshold: 7.00
CREATE TABLE expensive_books AS
SELECT isbn, book_title, rental_price
FROM books
WHERE rental_price > 7.00;

SELECT *
FROM expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT * 
FROM issued_status as ist
LEFT JOIN return_status as rs
	ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

-- Task 13: Retrieve the List of Books Returned
SELECT * 
FROM issued_status as ist
LEFT JOIN return_status as rs
	ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NOT NULL;

-- Task 14: Branch Performance Report
/* Create a query that generates a performance report for each branch, 
showing the number of books issued, 
the number of books returned, 
and the total revenue generated from book rentals.
*/
DROP TABLE IF EXISTS branch_reports;
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    e2.emp_name AS manager,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
JOIN employees AS e2
	ON b.manager_id = e2.emp_id
GROUP BY b.branch_id,b.manager_id;

SELECT * FROM branch_reports;

-- Task 15: Create a Table of Active Members
/* 
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
containing members who have issued at least one book in the last 2 months.
*/
CREATE TABLE active_members AS 
SELECT *
FROM members
WHERE member_id IN ( 
	SELECT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURDATE() - INTERVAL 180 DAY)
;
SELECT *
FROM active_members;

-- Task 16: Find Employees with the Most Book Issues Processed
/* 
Query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM branch;

SELECT e.emp_id, e.emp_name, COUNT(*) AS no_books_issued, b.* 
FROM employees AS e
JOIN issued_status AS i
	ON e.emp_id = i.issued_emp_id
JOIN branch AS b
	ON e.branch_id = b.branch_id
GROUP BY e.emp_id, e.emp_name
ORDER BY no_books_issued DESC
LIMIT 3;
