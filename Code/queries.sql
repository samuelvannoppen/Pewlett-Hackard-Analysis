-- Creating queries for PH_EmployeeDB 
-- Query confirmation
SELECT *
FROM employees;

-- Determining retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

-- refined search for 1952 births
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

-- refined search for 1953 births
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31';

-- refined search for 1954 births
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31';

-- refined search for 1955 births
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31';

-- refined retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- number of employees within the refined eligiblity
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- creating retirement table for export csv
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Query confirmation
SELECT *
FROM retirement_info;

-- recreating the refined retirrement_info with emp_no
DROP TABLE retirement_info;

SELECT emp_no,
	first_name,
	last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- query confirmation 
SELECT *
FROM retirement_info;

-- Joining departments and dept_manager tables
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments AS d
	INNER JOIN dept_manager AS dm
		ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables, creating new table to hold query
SELECT ri.emp_no,
    ri.first_name,
	ri.last_name,
    de.to_date
INTO current_emp
FROM retirement_info AS ri
	LEFT JOIN dept_emp AS de
		ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

-- Creating eligable retirees in departments
SELECT COUNT(ce.emp_no), de.dept_no
INTO emp_elg_dept
FROM current_emp AS ce
	LEFT JOIN dept_emp AS de
		ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

-- 1. Creating employee information table
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees AS e
	INNER JOIN salaries AS s
		ON e.emp_no = s.emp_no
	INNER JOIN dept_emp AS de
		ON e.emp_no = de.emp_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	AND (de.to_date = '9999-01-01');

-- 2. Creating management information table
SELECT dm.dept_no,
	d.dept_name,
	dm.emp_no,
	cu.last_name,
	cu.first_name,
	dm.from_date,
	dm.to_date
INTO manager_info
FROM dept_manager AS dm
	INNER JOIN departments AS d
		ON dm.dept_no = d.dept_no
	INNER JOIN current_emp AS cu
		ON dm.emp_no = cu.emp_no;
		
-- 3. Creating department retirees table
SELECT cu.emp_no,
	cu.first_name,
	cu.last_name,
	d.dept_name
INTO dept_info
FROM current_emp AS cu
	INNER JOIN dept_emp AS de
		ON cu.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON de.dept_no = d.dept_no;

-- Creating sales department retirement table
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	d.dept_name
INTO sales_retirement_info
FROM employees AS e
	INNER JOIN dept_emp AS de
		ON e.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON de.dept_no = d.dept_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	AND (dept_name = 'Sales');
	
-- creating table containing retires for sales + development
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	d.dept_name
INTO sales_dev_retirement_info
FROM employees AS e
	INNER JOIN dept_emp AS de
		ON e.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON de.dept_no = d.dept_no
WHERE dept_name IN ('Sales', 'Development')
	AND(birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
	
-- retirement titles table
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	ti.title,
	ti.from_date,
	ti.to_date
INTO retirement_titles
FROM employees AS e
	INNER JOIN titles AS ti
		ON e.emp_no = ti.emp_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
	
-- unique titles table
SELECT DISTINCT ON (emp_no) e.emp_no,
	e.first_name,
	e.last_name,
	ti.title,
	ti.from_date,
	ti.to_date
INTO unique_titles
FROM employees AS e
	INNER JOIN titles AS ti
	ON e.emp_no = ti.emp_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	AND (to_date = '9999-01-01')
ORDER BY emp_no, to_date DESC;

-- retiring titles table
SELECT COUNT(title), title
INTO retiring_titles
FROM unique_titles
GROUP BY title
ORDER BY COUNT DESC;
