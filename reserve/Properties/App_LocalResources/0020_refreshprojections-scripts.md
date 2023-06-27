ALTER procedure [dbo].[sp_app_rvw_proj1] @firm smallint, @project nvarchar(10), @revision smallint, @keepedits bit=1 as

SET nocount ON

declare @rpt_effective smallint, @rem_use_life smallint, @begin_bal float, @int float, @infl float
select @rpt_effective=year(report_effective), @begin_bal=begin_balance, @int=isnull(interest,0), @infl=isnull(inflation,0) from info_project_info where firm_id=@firm and project_id=@project and revision_id=@revision

DECLARE @Components TABLE (year_id smallint, category_id smallint, category_desc varchar(50), component_id smallint, component_desc varchar(75), comp_quantity int, comp_unit varchar(2), unit_cost float, res_req_pres_dols float, begin_bal float, begin_bal_calcd float, est_useful_life smallint, est_rem_useful_life smallint, annual_res_fund_req float, annual_res_fund_req_year2 float, full_fund_bal float, comp_note smallint, adjustment float, existing_reserve_fund float, expensed float, current_contrib float, primary key (year_id, category_id, component_id))

BEGIN TRANSACTION

	insert into @Components (year_id, category_id, category_desc, component_id, component_desc, comp_quantity, comp_unit, unit_cost, res_req_pres_dols, est_useful_life, est_rem_useful_life, begin_bal, full_fund_bal, current_contrib)

	select ly.year_id+1 as year_id, icc.category_id, icc.category_desc, ic.component_id, ic.component_desc, ic.comp_quantity, ic.comp_unit, dbo.fn_comp_int(@infl,ic.unit_cost,ly.year_id-1) as unit_cost, isnull(ic.comp_quantity,0)*dbo.fn_comp_int(@infl,ic.unit_cost,ly.year_id-1), ic.est_useful_life, ic.est_remain_useful_life, ipi.begin_balance,
	((ic.comp_quantity*dbo.fn_comp_int(@infl,ic.unit_cost,ly.year_id-1))/ic.est_useful_life)*(ic.est_useful_life-ic.est_remain_useful_life) as full_fund_bal,
	ipi.current_contrib
	from
	lkup_years ly inner join
	info_component_categories icc on icc.firm_id=@firm and icc.project_id=@project and icc.revision_id=@revision
	inner join info_components ic on ic.year_id=1 and icc.firm_id=ic.firm_id and icc.project_id=ic.project_id and icc.revision_id=ic.revision_id and icc.category_id=ic.category_id
	left join info_components ic_fut on ic_fut.year_id>1 and ly.year_id=ic_fut.year_id and ic.firm_id=ic_fut.firm_id and ic.project_id=ic_fut.project_id and ic.revision_id=ic_fut.revision_id and ic.category_id=ic_fut.category_id and ic.component_id=ic_fut.component_id
	inner join info_project_info ipi on ic.firm_id=ipi.firm_id and ic.project_id=ipi.project_id and ic.revision_id=ipi.revision_id
	where ic_fut.firm_id is null

	union

	select ic.year_id+1, icc.category_id, icc.category_desc, ic.component_id, ic.component_desc, ic.comp_quantity, ic.comp_unit, dbo.fn_comp_int(@infl,ic.unit_cost,ic.year_id-1) as unit_cost, isnull(ic.comp_quantity,0)*dbo.fn_comp_int(@infl,ic.unit_cost,ic.year_id-1), ic.est_useful_life, ic.est_remain_useful_life, ipi.begin_balance,
	((ic.comp_quantity*dbo.fn_comp_int(@infl,ic.unit_cost,ic.year_id-1))/ic.est_useful_life)*(ic.est_useful_life-ic.est_remain_useful_life) as full_fund_bal,
	ipi.current_contrib
	from
	info_component_categories icc
	inner join info_components ic on icc.firm_id=ic.firm_id and icc.project_id=ic.project_id and icc.revision_id=ic.revision_id and icc.category_id=ic.category_id
	inner join info_project_info ipi on ic.firm_id=ipi.firm_id and ic.project_id=ipi.project_id and ic.revision_id=ipi.revision_id
	where icc.firm_id=@firm and icc.project_id=@project and icc.revision_id=@revision and ic.year_id>1

	order by year_id

	update @Components set est_rem_useful_life=dbo.fn_est_rem_use_life(@firm,@project,@revision,year_id,category_id,component_id)
	update @Components set begin_bal_calcd=0 from @Components c where begin_bal=0 or (select sum(full_fund_bal) from @Components where year_id=c.year_id)=0 
	update @Components set begin_bal_calcd=(full_fund_bal/(select sum(full_fund_bal) from @Components where year_id=c.year_id))*begin_bal from @Components c where begin_bal_calcd is null
	update @Components set expensed=case when est_useful_life=est_rem_useful_life then res_req_pres_dols else 0 end
	
	update @Components set adjustment=(res_req_pres_dols/est_useful_life)*(est_useful_life-est_rem_useful_life)

	--Year 2 calc only
	update @Components set annual_res_fund_req_year2=(res_req_pres_dols-begin_bal_calcd)/case when est_rem_useful_life+1>est_useful_life then 1 else est_rem_useful_life+1 end where year_id=2
	update @Components set existing_reserve_fund=(adjustment/(select sum(adjustment) from @Components where year_id=2))*((select sum(annual_res_fund_req_year2) from @Components where year_id=2)+begin_bal-(select sum(expensed) from @components where year_id=2)) where year_id=2
	update @Components set annual_res_fund_req=(res_req_pres_dols-existing_reserve_fund)/est_rem_useful_life where year_id=2

COMMIT TRANSACTION

DECLARE @Totals TABLE (year_id smallint, annual_exp int, interest float, cfa_annual_contrib int, cfa_reserve_fund_bal int, ffa_req_annual_contr int, ffa_avg_req_annual_contr int, ffa_res_fund_bal int, bfa_annual_contr int, ext_res_cur_year int, bfa_res_fund_bal int, full_fund_bal int, pct_increase float primary key (year_id))

begin transaction

insert into @Totals (year_id, annual_exp, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ext_res_cur_year)

select year_id, sum(expensed) as annual_exp, current_contrib as cfa_annual_contrib, 
case when year_id=2 then begin_bal+current_contrib-sum(expensed) end as cfa_reserve_fund_bal, 
sum(annual_res_fund_req_year2) as ffa_req_annual_contr,
case when year_id=2 then ((select sum(annual_res_fund_req_year2) from @Components where year_id=2)+begin_bal-(select sum(expensed) from @components where year_id=2)) end
from @Components group by year_id, current_contrib, begin_bal, current_contrib order by year_id

commit transaction

update @Totals set cfa_reserve_fund_bal=(select cfa_reserve_fund_bal from @Totals where year_id=t.year_id-1) from @Totals t where year_id>2
update @Totals set ffa_req_annual_contr=(select sum(annual_res_fund_req)*POWER(1+(@infl/100),1) from @Components where year_id=2) where year_id=3

DECLARE @yr smallint = 3;
WHILE @yr < 32
BEGIN
	update @Components set existing_reserve_fund=
		dbo.fn_rvw_comp_zeroval(adjustment,(select sum(adjustment) from @Components where year_id=@yr))
		* ((select sum(annual_res_fund_req) from @Components where year_id=@yr-1)
		  +(select ext_res_cur_year from @Totals where year_id=@yr-1)
		  -(select sum(expensed) from @Components where year_id=@yr)) 
	where year_id=@yr

	update @Components set annual_res_fund_req=(res_req_pres_dols-existing_reserve_fund)/est_rem_useful_life where year_id=@yr
	
	update @Totals set cfa_reserve_fund_bal=((select cfa_reserve_fund_bal from @Totals where year_id=@yr-1)+cfa_annual_contrib-annual_exp),
		ffa_req_annual_contr=case when @yr=3 then ffa_req_annual_contr else (select sum(annual_res_fund_req) from @Components where year_id=@yr-1) end,
		ext_res_cur_year=((select sum(annual_res_fund_req) from @Components where year_id=@yr-1)+(select ext_res_cur_year from @Totals where year_id=@yr-1)-(select sum(expensed) from @Components where year_id=@yr))
		where year_id=@yr

	set @yr=@yr+1;
END;

update @Totals set ffa_avg_req_annual_contr=(select avg(ffa_req_annual_contr) from @Totals)
--Interest
update @Totals set ffa_res_fund_bal=(@begin_bal+ffa_avg_req_annual_contr-annual_exp), cfa_reserve_fund_bal=(@begin_bal+cfa_annual_contrib-annual_exp) where year_id=2
update @Totals set ffa_res_fund_bal=(select ffa_res_fund_bal from @Totals where year_id=t.year_id-1)+ffa_avg_req_annual_contr-annual_exp from @Totals t where t.year_id=4
--Full fund bal for each year
update @Totals set full_fund_bal=(select sum(((
		isnull(vw.comp_quantity,0)
		*dbo.fn_comp_int(@infl,vw.unit_cost,year_id))/vw.est_useful_life)
		*(vw.est_useful_life-vw.est_remain_useful_life))
	from vw_app_rvw_fullfundbal vw
	where vw.firm_id=@firm and vw.project_id=@project and vw.revision_id=@revision and vw.year_id=t.year_id
	group by vw.year_id)
	from @Totals t

set @yr = 3;
WHILE @yr < 32
BEGIN
	update @Totals set ffa_res_fund_bal=((select ffa_res_fund_bal from @Totals where year_id=@yr-1)+ffa_avg_req_annual_contr-annual_exp)*(1+(@int/100)),
	cfa_reserve_fund_bal=((select cfa_reserve_fund_bal from @Totals where year_id=@yr-1)+cfa_annual_contrib-annual_exp)*(1+(@int/100))
	where year_id=@yr
	set @yr=@yr+1
end;

update @Totals set year_id=year_id+@rpt_effective-2
if @keepedits=1 update @Totals set pct_increase=i.pct_increase from @Totals t inner join info_projections i on i.firm_id=@firm and i.project_id=@project and i.revision_id=@revision and i.year_id=t.year_id

delete from info_projections where firm_id=@firm and project_id=@project and revision_id=@revision
insert into info_projections (firm_id, project_id, revision_id, year_id, annual_exp, interest, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, ext_res_cur_year, full_fund_bal, pct_increase)
select @firm, @project, @revision, year_id, annual_exp, interest, cfa_annual_contrib, cfa_reserve_fund_bal, ffa_req_annual_contr, ffa_avg_req_annual_contr, ffa_res_fund_bal, ext_res_cur_year, full_fund_bal, pct_increase from @Totals
