# LinkedIn post copy

I’ve completed the SQL phase of an independent portfolio project analysing public 2024 British Grand Prix data.

The aim was not to claim access to team telemetry or reduce driver performance to one number. I wanted to practise turning a stakeholder question into a reproducible analysis while being clear about data quality, assumptions and limitations.

What I completed:

- Built a relational SQL Server database in Docker from six public race-data tables.
- Used joins, grouped aggregates, CTEs, NOT EXISTS, STDEV() and RANK().
- Checked row grain, duplicate risk and NULL handling.
- Created a documented cleaning rule that removes lap 1, pit-stop laps, the immediately following laps and unusually slow laps outside a driver-specific threshold.
- Verified every numbered exercise against the database before publishing the repository.

I also deliberately leveraged AI while learning SQL. I used it as an on-demand tutor and debugging partner to explain unfamiliar concepts, challenge my reasoning and help structure the project into small, step-by-step tasks. I completed the hands-on analysis myself and made sure I could explain the joins, filters, aggregations and assumptions rather than treating AI output as a substitute for understanding.

The next phase will be a Tableau dashboard, which I will add separately after validating the visualisations and findings.

GitHub: https://github.com/crrishjoshi/f1-silverstone-sql-project

Race timing, result and pit-stop data: Jolpica F1 API, used under CC BY-NC-SA 4.0. Independent educational analysis; not affiliated with Formula 1 or any team.

#SQL #BusinessAnalysis #DataAnalysis #Motorsport #LearningInPublic
