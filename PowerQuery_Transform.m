// ============================================================
// BEVERAGE SALES — POWER QUERY M TRANSFORMATIONS
// Paste each section into the Power Query Editor
// ============================================================


// ── STEP 1: LOAD & CLEAN SALES TABLE ─────────────────────────
let
    Source = Csv.Document(
        File.Contents("C:\Users\elezi\Downloads\Beverage Sales\synthetic_beverage_sales_data.csv"),
        [Delimiter=",", Columns=11, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),

    // Promote headers
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),

    // Set data types
    TypedTable = Table.TransformColumnTypes(PromotedHeaders, {
        {"Order_ID",       type text},
        {"Customer_ID",    type text},
        {"Customer_Type",  type text},
        {"Product",        type text},
        {"Category",       type text},
        {"Unit_Price",     type number},
        {"Quantity",       Int64.Type},
        {"Discount",       type number},
        {"Total_Price",    type number},
        {"Region",         type text},
        {"Order_Date",     type date}
    }),

    // Add calculated columns
    AddYear = Table.AddColumn(TypedTable, "Year",
        each Date.Year([Order_Date]), Int64.Type),

    AddMonth = Table.AddColumn(AddYear, "Month",
        each Date.Month([Order_Date]), Int64.Type),

    AddMonthName = Table.AddColumn(AddMonth, "Month Name",
        each Date.ToText([Order_Date], "MMM"), type text),

    AddQuarter = Table.AddColumn(AddMonthName, "Quarter",
        each "Q" & Text.From(Date.QuarterOfYear([Order_Date])), type text),

    AddYearMonth = Table.AddColumn(AddQuarter, "Year-Month",
        each Date.ToText([Order_Date], "yyyy-MM"), type text),

    // Discount bucket
    AddDiscountBucket = Table.AddColumn(AddYearMonth, "Discount Tier", each
        if [Discount] = 0    then "No Discount"
        else if [Discount] <= 0.05 then "Low (1-5%)"
        else if [Discount] <= 0.10 then "Medium (6-10%)"
        else "High (>10%)",
        type text
    ),

    // Revenue before discount
    AddGrossRevenue = Table.AddColumn(AddDiscountBucket, "Gross Revenue",
        each [Unit_Price] * [Quantity], type number),

    // Discount value in €
    AddDiscountValue = Table.AddColumn(AddGrossRevenue, "Discount Value (€)",
        each [Gross Revenue] - [Total_Price], type number),

    // Margin proxy (assume ~40% COGS for non-alcohol, ~30% for alcohol)
    AddCOGS = Table.AddColumn(AddDiscountValue, "Est. COGS", each
        if [Category] = "Alcoholic Beverages" then [Total_Price] * 0.30
        else [Total_Price] * 0.40,
        type number
    ),

    AddMargin = Table.AddColumn(AddCOGS, "Est. Gross Margin",
        each [Total_Price] - [Est. COGS], type number),

    AddMarginPct = Table.AddColumn(AddMargin, "Est. Margin %",
        each ([Total_Price] - [Est. COGS]) / [Total_Price], type number),

    // Sort by date
    Sorted = Table.Sort(AddMarginPct, {{"Order_Date", Order.Ascending}})

in
    Sorted


// ── STEP 2: DATE DIMENSION TABLE ─────────────────────────────
// Create a standalone Date table and link to Sales[Order_Date]
let
    StartDate = #date(2021, 1, 1),
    EndDate   = #date(2023, 12, 31),

    DayCount = Duration.Days(EndDate - StartDate) + 1,
    DateList = List.Dates(StartDate, DayCount, #duration(1, 0, 0, 0)),
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),

    TypedDate = Table.TransformColumnTypes(DateTable, {{"Date", type date}}),

    AddYear = Table.AddColumn(TypedDate, "Year",
        each Date.Year([Date]), Int64.Type),
    AddQuarter = Table.AddColumn(AddYear, "Quarter",
        each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    AddQuarterNo = Table.AddColumn(AddQuarter, "Quarter No",
        each Date.QuarterOfYear([Date]), Int64.Type),
    AddMonth = Table.AddColumn(AddQuarterNo, "MonthNo",
        each Date.Month([Date]), Int64.Type),
    AddMonthName = Table.AddColumn(AddMonth, "Month",
        each Date.ToText([Date], "MMMM"), type text),
    AddMonthShort = Table.AddColumn(AddMonthName, "Month Short",
        each Date.ToText([Date], "MMM"), type text),
    AddWeekday = Table.AddColumn(AddMonthShort, "Weekday",
        each Date.ToText([Date], "dddd"), type text),
    AddWeekdayNo = Table.AddColumn(AddWeekday, "Weekday No",
        each Date.DayOfWeek([Date], Day.Monday) + 1, Int64.Type),
    AddIsWeekend = Table.AddColumn(AddWeekdayNo, "Is Weekend",
        each Date.DayOfWeek([Date]) = 0 or Date.DayOfWeek([Date]) = 6, type logical),
    AddYearMonth = Table.AddColumn(AddIsWeekend, "Year-Month",
        each Date.ToText([Date], "yyyy-MM"), type text),
    AddYearQuarter = Table.AddColumn(AddYearMonth, "Year-Quarter",
        each Text.From(Date.Year([Date])) & "-" &
             "Q" & Text.From(Date.QuarterOfYear([Date])), type text)

in
    AddYearQuarter


// ── STEP 3: CATEGORY DIMENSION TABLE ─────────────────────────
let
    CategoryData = Table.FromRows(
        {
            {"Alcoholic Beverages", "Spirits & Wine",   "#C0392B", "🍷"},
            {"Juices",             "Non-Alcoholic",     "#E67E22", "🍊"},
            {"Soft Drinks",        "Non-Alcoholic",     "#2980B9", "🥤"},
            {"Water",              "Non-Alcoholic",     "#27AE60", "💧"}
        },
        {"Category", "Segment", "Color Hex", "Icon"}
    )
in
    CategoryData


// ── STEP 4: REGION DIMENSION TABLE ─────────────────────────────
let
    RegionData = Table.FromRows(
        {
            {"Baden-Württemberg",       "South",     "BW"},
            {"Bayern",                  "South",     "BY"},
            {"Berlin",                  "Northeast", "BE"},
            {"Brandenburg",             "Northeast", "BB"},
            {"Bremen",                  "Northwest", "HB"},
            {"Hamburg",                 "Northwest", "HH"},
            {"Hessen",                  "Central",   "HE"},
            {"Mecklenburg-Vorpommern",  "Northeast", "MV"},
            {"Niedersachsen",           "Northwest", "NI"},
            {"Nordrhein-Westfalen",     "West",      "NW"},
            {"Rheinland-Pfalz",         "West",      "RP"},
            {"Saarland",               "West",      "SL"},
            {"Sachsen",                "East",      "SN"},
            {"Sachsen-Anhalt",         "East",      "ST"},
            {"Schleswig-Holstein",     "Northwest", "SH"},
            {"Thüringen",              "East",      "TH"}
        },
        {"Region", "Area", "State Code"}
    )
in
    RegionData
