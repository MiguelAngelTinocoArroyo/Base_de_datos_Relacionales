


# 1. La ciudad con el mayor número total de ventas.

select City as ciudad_max_ventas
from(
    select City, sum(Quantity) as total_ventas
    from supermarket_sales
    group by City
    order by total_ventas desc
    limit 1
) t1;

# 2. El producto más vendido en dicha ciudad.

select product_line as producto_mas_vendido
from(
    select City, product_line, sum(Quantity) as total_ventas
    from supermarket_sales
    where City = (
        select City
        from (
            select City, sum(Quantity) as total_ventas
            from supermarket_sales
            group by City
            order by total_ventas desc
            limit 1
             ) t2
     )
    group by City, product_line
    order by total_ventas desc
    limit 1) t3;

   
   
# 3. El método de pago más común para las transacciones en esa ciudad.
   
select Payment as metodo_pago_comun
from(
    select City, Payment, count(*) as total_transacciones
    from supermarket_sales
    where City = (
        select City
        from (
            select City, sum(Quantity) as total_ventas
            from supermarket_sales
            group by City
            order by total_ventas desc
            limit 1
        ) t4
    )
    group by City, Payment
    order by total_transacciones desc
    limit 1
) t5;




# 4. El promedio de calificación (Rating) de los clientes para las transacciones en esa ciudad.

select avg(Rating) as promedio_calificacion_clientes
from supermarket_sales
where City = (
    select City
    from (
        select City, sum(Quantity) as total_ventas
        from supermarket_sales
        group by City
        order by total_ventas desc
        limit 1
    ) t6
);






# 5. Crear una vista y mostrar las 5 transacciones con los totales más altos de esa ciudad.

create or replace view Top5Transacciones as
select *
from supermarket_sales
where City = (
    select City
    from (
        select City, sum(Quantity) as total_ventas
        from supermarket_sales
        group by City
        order by total_ventas desc
        limit 1
    ) t7
)
order by Quantity desc
limit 5;

select * from Top5Transacciones;


# 6. Desarrolle una única consulta SQL que le permita obtener toda la 
# la información. (En este caso podría craerse una vista encapsulando todo el query)

create or replace view AnalisisSupermercado as
with ciudad_max_ventas as (
    select City, sum(Quantity) as total_ventas
    from supermarket_sales
    group by City
    order by total_ventas desc
    limit 1
), producto_mas_vendido as (
    select City, product_line, sum(Quantity) as total_ventas_producto
    from supermarket_sales
    where City = (select City from ciudad_max_ventas)
    group by City, product_line
    order by total_ventas_producto desc
    limit 1
), metodo_pago_comun as (
    select City, Payment, count(*) as total_transacciones
    from supermarket_sales
    where City = (select City from ciudad_max_ventas)
    group by City, Payment
    order by total_transacciones desc
    limit 1
)
select
    ciudad_max_ventas.City as ciudad_max_ventas,
    producto_mas_vendido.product_line as producto_mas_vendido,
    metodo_pago_comun.Payment as metodo_pago_comun,
    avg(supermarket_sales.Rating) as promedio_calificacion_clientes
from
    ciudad_max_ventas
    join producto_mas_vendido on ciudad_max_ventas.City = producto_mas_vendido.City
    join metodo_pago_comun on ciudad_max_ventas.City = metodo_pago_comun.City
    join supermarket_sales on ciudad_max_ventas.City = supermarket_sales.City
group by ciudad_max_ventas.City, producto_mas_vendido.product_line, metodo_pago_comun.Payment;

select * from AnalisisSupermercado;
select current_time() 
set global event_scheduler = on;

create event metricas 
on schedule every 1 day 
starts timestamp(current_date, '13:00:00')
do
begin 
	select * from AnalisisSupermercado;
end;
show events;











