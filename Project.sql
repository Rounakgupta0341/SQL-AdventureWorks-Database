--Employee Chek IN and check out Calculation
--To meet the company's requirements, need to calculate the total work hours of employees in a day based on their check-in and check-out times.
--ReadMe
--In the SQL project I developed, the primary goal was to create a system that accurately tracks and calculates the total work hours of employees based on their check-in and check-out times. This project is essential for companies looking to streamline attendance management and ensure precise records of employee work hours.

--The process begins with the creation of an EmployeeWorkLog table that records each employee's check-in and check-out times. Using SQL queries, the project identifies the first check-in and the last check-out for each employee on a given day, which are crucial for calculating total work hours. The FirstCheckIn and LastCheckOut common table expressions (CTEs) isolate these critical timestamps for each employee.

--To handle scenarios where employees may check in and out multiple times in a day, the project includes a WorkSessions CTE, which pairs each check-in with the subsequent check-out. This ensures that the system accurately captures all work periods. The TotalOutCount CTE tracks the number of check-outs, providing an additional layer of verification to ensure all work sessions are accounted for.

--Finally, the TotalWorkHours CTE calculates the total work minutes by summing the duration of each work session, converting these minutes into a standard hours and minutes format. The final SELECT statement compiles all the relevant data, including the first check-in, last check-out, total check-outs, and total work hours for each employee.

--This SQL project not only meets the company's requirements for accurate work hour calculation but also provides a robust solution that can handle various attendance scenarios, ensuring reliable and efficient workforce management.


WITH EmployeeWorkLog AS (
    SELECT
        EmpID,
        Name,
        TO_TIMESTAMP("CheckIn-CheckOut Time", 'DD-MM-YYYY HH24:MI') AS LogTime,
        Attendance
    FROM
        EmployeeLog
),
FirstCheckIn AS (
    SELECT
        EmpID,
        Name,
        MIN(LogTime) AS FirstCheckInTime
    FROM
        EmployeeWorkLog
    WHERE
        Attendance = 'IN'
    GROUP BY
        EmpID, Name
),
LastCheckOut AS (
    SELECT
        EmpID,
        Name,
        MAX(LogTime) AS LastCheckOutTime
    FROM
        EmployeeWorkLog
    WHERE
        Attendance = 'OUT'
    GROUP BY
        EmpID, Name
),
TotalOutCount AS (
    SELECT
        EmpID,
        Name,
        COUNT(*) AS TotalOutCount
    FROM
        EmployeeWorkLog
    WHERE
        Attendance = 'OUT'
    GROUP BY
        EmpID, Name
),
WorkSessions AS (
    SELECT
        e1.EmpID,
        e1.Name,
        e1.LogTime AS CheckInTime,
        MIN(e2.LogTime) AS CheckOutTime
    FROM
        EmployeeWorkLog e1
    JOIN
        EmployeeWorkLog e2 ON e1.EmpID = e2.EmpID
    WHERE
        e1.Attendance = 'IN'
        AND e2.Attendance = 'OUT'
        AND e1.LogTime < e2.LogTime
    GROUP BY
        e1.EmpID, e1.Name, e1.LogTime
),
TotalWorkHours AS (
    SELECT
        EmpID,
        Name,
        SUM(EXTRACT(HOUR FROM (CheckOutTime - CheckInTime)) * 60 + EXTRACT(MINUTE FROM (CheckOutTime - CheckInTime))) AS TotalWorkMinutes
    FROM
        WorkSessions
    GROUP BY
        EmpID, Name
)
SELECT
    FC.EmpID,
    FC.Name,
    FC.FirstCheckInTime,
    LC.LastCheckOutTime,
    TOC.TotalOutCount,
    TO_CHAR(FLOOR(TWH.TotalWorkMinutes / 60), 'FM00') || ':' || LPAD(MOD(TWH.TotalWorkMinutes, 60), 2, '0') AS TotalWorkHours
FROM
    FirstCheckIn FC
JOIN
    LastCheckOut LC ON FC.EmpID = LC.EmpID
JOIN
    TotalOutCount TOC ON FC.EmpID = TOC.EmpID
JOIN
    TotalWorkHours TWH ON FC.EmpID = TWH.EmpID;
