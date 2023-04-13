-- 1) The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values:
-- facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

insert into cd.facilities
values
  (9, 'spa', 20, 30, 1000000, 800);

-- 2) Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate
-- the value for the next facid, rather than specifying it as a constant. Use the following values for everything else:
-- Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

-- Used sub-query as facid does not have auto increment constraint
insert into cd.facilities
values
  (
    (
      select
        max(facid)
      from
        cd.facilities
    )+ 1,
    'spa',
    20,
    30,
    1000000,
    800
  );

-- 3) We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than
-- 8000: you need to alter the data to fix the error.

-- facid starts with 0, that's why selecting 1 for second tennis court
Update
  cd.facilities
set
  "initialoutlay" = 100000
where
  facid = 1;

-- 4) We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this
-- without using constant values for the prices, so that we can reuse the statement if we want to.

UPDATE
  cd.facilities
set
  membercost = membercost +(
    (
      select
        membercost
      from
        cd.facilities
      where
        facid = 0
    )* 0.1
  ),
  guestcost = guestcost +(
    (
      select
        guestcost
      from
        cd.facilities
      where
        facid = 0
    )* 0.1
  )
where
  facid = 1;

-- 5) As part of a clearout of our database, we want to delete all bookings from the cd.bookings table.
-- How can we accomplish this?

-- truncate will delete all the rows at once.
truncate table cd.bookings;

-- 6) We want to remove member 37, who has never made a booking, from our database. How can we achieve that?

delete from
  cd.members
where
  memid = 37;

 -- 7) How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the
 -- monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities
 -- in question.

 select
   facid,
   name,
   membercost,
   monthlymaintenance
 from
   cd.facilities
 where
   membercost > 0
   and (
     membercost < monthlymaintenance / 50.0
   );

-- 8) How can you produce a list of all facilities with the word 'Tennis' in their name?

select
  *
from
  cd.facilities
where
  name like '%Tennis%';

-- 9) How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.

select
  *
from
  cd.facilities
where
  facid in (1, 5);

-- 10) How can you produce a list of members who joined after the start of September 2012? Return the memid, surname,
-- firstname, and joindate of the members in question.

select
  memid,
  surname,
  firstname,
  joindate
from
  cd.members
where
  joindate >= '2012-09-01';

-- 11) You, for some reason, want a combined list of all surnames and all facility names. Yes, this is a contrived
-- example :-). Produce that list!

select
  surname
from
  cd.members
union
select
  name
from
  cd.facilities;

-- 12) How can you produce a list of the start times for bookings by members named 'David Farrell'?

select
  b.starttime
from
  cd.bookings b
  inner join cd.members m on m.memid = b.memid
where
  m.firstname = 'David'
  and m.surname = 'Farrell';

-- 13) How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return
-- a list of start time and facility name pairings, ordered by the time.

select
  b.starttime as start,
  f.name as name
from
  cd.facilities f
  inner join cd.bookings b on f.facid = b.facid
where
  f.name in (
    'Tennis Court 2', 'Tennis Court 1'
  )
  and b.starttime >= '2012-09-21'
  and b.starttime < '2012-09-22'
order by
  b.starttime;

-- 14) How can you output a list of all members, including the individual who recommended them (if any)? Ensure
-- that results are ordered by (surname, firstname).

select
  mems.firstname as memfname,
  mems.surname as memsname,
  recs.firstname as recfname,
  recs.surname as recsname
from
  cd.members mems
  left outer join cd.members recs on recs.memid = mems.recommendedby
order by
  memsname,
  memfname;

-- 15) How can you output a list of all members who have recommended another member? Ensure that there are no duplicates
-- in the list, and that results are ordered by (surname, firstname).

select
  distinct recs.firstname as firstname,
  recs.surname as surname
from
  cd.members mems
  inner join cd.members recs on recs.memid = mems.recommendedby
order by
  surname,
  firstname;

-- 16) How can you output a list of all members, including the individual who recommended them (if any), without using
-- any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.

select
  distinct mems.firstname || ' ' || mems.surname as member,
  (
    select
      recs.firstname || ' ' || recs.surname as recommender
    from
      cd.members recs
    where
      recs.memid = mems.recommendedby
  )
from
  cd.members mems
order by
  member;

-- 17) Produce a count of the number of recommendations each member has made. Order by member ID.

select recommendedby, count(*)
	from cd.members
	where recommendedby is not null
	group by recommendedby
order by recommendedby;

-- 18) Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting
-- of facility id and slots, sorted by facility id.

select
  facid,
  sum(slots) as "Total Slots"
from
  cd.bookings
group by
  facid
order by
  facid;

-- 19) Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output
-- table consisting of facility id and slots, sorted by the number of slots.

select
  facid,
  sum(slots) as "Total Slots"
from
  cd.bookings
where
  starttime >= '2012-09-01'
  and starttime < '2012-10-01'
group by
  facid
order by
  sum(slots);

--20) Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output
-- table consisting of facility id and slots, sorted by the id and month.

select
  facid,
  extract(
    month
    from
      starttime
  ) as month,
  sum(slots) as "Total Slots"
from
  cd.bookings
where
  extract(
    year
    from
      starttime
  ) = 2012
group by
  facid,
  month
order by
  facid,
  month;

-- 21) Find the total number of members (including guests) who have made at least one booking.

select
  count(distinct memid)
from
  cd.bookings;

-- 22) Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.

select
  mems.surname,
  mems.firstname,
  mems.memid,
  min(bks.starttime) as starttime
from
  cd.bookings bks
  inner join cd.members mems on mems.memid = bks.memid
where
  starttime >= '2012-09-01'
group by
  mems.surname,
  mems.firstname,
  mems.memid
order by
  mems.memid;

-- 23) Produce a list of member names, with each row containing the total member count. Order by join date, and include
-- guest members.

-- the OVER clause defines a window or user-specified set of rows within a query result set.
select
  count(*) over(),
  firstname,
  surname
from
  cd.members
order by
  joindate;

-- 24) Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining.
-- Remember that member IDs are not guaranteed to be sequential.
select
  count(*) over(
    order by
      joindate
  ),
  firstname,
  surname
from
  cd.members
order by
  joindate;

-- 25) Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing
-- results get output.

select
  facid,
  total
from
  (
    select
      facid,
      sum(slots) total,
      rank() over (
        order by
          sum(slots) desc
      ) rank
    from
      cd.bookings
    group by
      facid
  ) as ranked
where
  rank = 1;

-- 26) Output the names of all members, formatted as 'Surname, Firstname'

select
  surname || ', ' || firstname as name
from
  cd.members;

--27) You've noticed that the club's member table has telephone numbers with very inconsistent formatting. You'd like
-- to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by
-- member ID.

select
  memid,
  telephone
from
  cd.members
where
  telephone similar to '%[()]%';

-- 28) You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet.
-- Sort by the letter, and don't worry about printing out a letter if the count is 0.

select
  substr (mems.surname, 1, 1) as letter,
  count(*) as count
from
  cd.members mems
group by
  letter
order by
  letter;