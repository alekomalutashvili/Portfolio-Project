--1.
--გამოვიტანოთ  სახელი და გვარი, დეპარტამენტი, სამსახურის სახელი და ხელფასი ყველა თანამშრომლისთვის,
--რომლებიც აიყავნეს სამსახურში 1994-დან 1997 წლამდე
select  first_name +' '+ last_name as N'სახელი გვარი',
		department_name, 
		job_title,
		salary    
from employees e
join  departments d on  e.department_id=d.department_id
join jobs j on e.job_id=j.job_id
where  year (hire_date)  between 1994 and 1997



--2
--გამოვიტანოთ ისეთი თანამშრომლები, რომლებსაც აქვთ საშუალოზე მაღალი ხელფასი
select first_name+''+last_name,
		avg(salary)    
from employees
where  salary >(select AVG(salary) from employees)
group by first_name+''+last_name



--3
--max_salary-ის მიხედვით შევქმნათ ახალი სვეტი, სადაც იმ შემთხვევაში თუ წერია 20 000-ზე ნაკლები ჩაწერე - დაბალი
												--  იმ შემთხვევაში თუ წერია 20 000-ზე მეტი და 40000-ზე ნაკლები - საშუალო
												-- 40 000-ზე მეტი - დიდი
select *,case 
          when max_salary < '20000'then N'დაბალი'
		  when max_salary between '20000' and '40000' then N'საშუალო'
		  when max_salary >= '40000' then N'დიდი'
		  end max_salary

from jobs

--4
-- გამოვიტანოთ მონაცემები, რომელიც გვაჩვენებს რომელ ქალაქში რამდენი ადამიანი მუშაობს.
select city ,
		count(employee_id) 

from locations l
join departments d on d.location_id=l.location_id
join employees e on e.department_id=d.department_id
group by city


--5
--გამოვთვალოთ თითოეული დეპარტამენტისთვის სახელფასო რეინჯი, ანუ თითოეული დეპარტამენტისთვის მაქიმალურ ხელფასს 
--გამოაკელი მინიმალური ხელფასი
select		department_name,
			MAX(max_salary)-MIN(min_salary) [სახელფასო რეინჯი]
from jobs j
join employees e on e.job_id=j.job_id
join departments d on d.department_id=e.department_id
where year(hire_date) between 1995 and 1999 
group by departmenT_name
order by department_name



--6
--ზემოთ გაკეთებული სკრიპტის საფუძველზე გავაკეთოთ პროცედურა, რომელიც გამოითვლის სახელფასო რეინჯს 
--თითოეული დეპარტამენტისთვის, ოღონდ არჩევის შესაძლებლობა უნდა გვქონდეს რომელი თარიღიდან არიან აყვანილები, მაგალითად
--თუ მოვნიშნე 1995-დან 1998 წლამდე, მაშინ პროცედურამ უნდა დამითვალოს სახელფასო რეინჯი მხოლოდ იმ თანამშრომლებისთვის,
--რომლებმაც მუშაობა დაიწყეს ამ პერიოდში.

Create PROCEDURE [dbo].[SalaryRange]
	@StarDate int,
	@Enddate int

AS
BEGIN
	select		department_name,
				MAX(max_salary)-MIN(min_salary) [სახელფასო რეინჯი]
	from jobs j
	join employees e on e.job_id=j.job_id
	join departments d on d.department_id=e.department_id
	where year(hire_date) between @StarDate and @Enddate 
	group by departmenT_name
	order by department_name

END


exec SalaryRange 1991,1999



--7 თითოეული დეპარტამენტისთვის გამოვიტანოთ ტოპ 2 ყველაზე მაღალ ხელფასიანი თანამშრომელი.
--უნდა გამოიტანო დეპარტამენტის სახელი და თანამშრომელბის სახელი და გვარები

select department_name,
		first_name+' ' + last_name fullname, 
		DENSE_RANK()  over (partition by e.department_id order by salary   desc) DR

into #temp
from [dbo].[employees] e
join departments d on e.department_id=d.department_id

select department_name,fullname  from #temp
where DR in (1,2)



--second way 
select * from (
		select department_name,
				first_name+' ' + last_name fullname,
				DENSE_RANK()  over (partition by e.department_id order by salary   desc) DR

		from [dbo].[employees] e
		join departments d on e.department_id=d.department_id
) a
where DR in(1,2)