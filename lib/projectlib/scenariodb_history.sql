------------------------------------------------------------------------
-- TITLE:
--    scenariodb_history.sql
--
-- AUTHOR:
--    Will Duquette
--
-- DESCRIPTION:
--    SQL Schema for scenariodb(n): Simulation History
--
-- These tables are used by both scenariodb(n) and experimentdb(n).  In
-- scenariodb(n), the case_id column is always 0.  In experimentdb(n),
-- the results of multiple cases are saved by setting case_id to the
-- case index, which runs from 1 to N.
--
------------------------------------------------------------------------

-- The following tables contain simulation history data for
-- "after-action analysis".  The tables are grouped by index; e.g.,
-- the hist_civg table contains civilian group outputs over time.

CREATE TABLE hist_nbhood (
    -- History: Neighborhood outputs
    t          INTEGER,
    n          TEXT,       -- Neighborhood name

    a          TEXT,       -- Name of actor controlling n, or NULL if none 
    nbmood     DOUBLE,     -- Neighborhood mood
    volatility INTEGER,    -- Volatility of neighborhood
    nbpop      INTEGER,    -- Civilian population of neighborhood
    nbsecurity INTEGER,    -- Average civilian security in neighborhood
    ur         DOUBLE,     -- Unemployment rate (%) in a neighborhood

    PRIMARY KEY (t,n)
);

CREATE VIEW hist_control AS 
SELECT t, n, a          
FROM hist_nbhood;

CREATE VIEW hist_nbmood AS 
SELECT t, n, nbmood
FROM hist_nbhood;

CREATE VIEW hist_volatility AS 
SELECT t, n, volatility 
FROM hist_nbhood;

CREATE VIEW hist_npop AS 
SELECT t, n, nbpop AS population 
FROM hist_nbhood;

CREATE VIEW hist_nbur AS
SELECT t, n, ur 
FROM hist_nbhood;

CREATE TABLE hist_nbgroup (
    -- History: Neighborhood group outputs
    t          INTEGER,
    n          TEXT,      -- Neighborhood name
    g          TEXT,      -- CIV/FRC/ORG group name

    security   INTEGER,   -- g's security in n
    personnel  INTEGER,   -- The population or personnel of g in n
    unassigned INTEGER,   -- For ORG/FRC groups number of unassigned personnel

    PRIMARY KEY (t,n,g)
);

CREATE VIEW hist_security AS
SELECT t, n, g, security
FROM hist_nbgroup;

CREATE VIEW hist_deploy_ng AS
SELECT t, n, g, personnel, unassigned
FROM hist_nbgroup
JOIN groups USING (g) WHERE gtype != 'CIV';

CREATE TABLE hist_civg (
    -- History: civilian group outputs
    t          INTEGER,
    g          TEXT,
    mood       DOUBLE,
    population INTEGER,

    PRIMARY KEY (t,g)
);

CREATE VIEW hist_mood AS
SELECT t, g, mood
FROM hist_civg;

CREATE VIEW hist_pop AS
SELECT t, g, population
FROM hist_civg;

CREATE TABLE hist_sat_raw (
    -- History: sat.g.c
    t        INTEGER,
    g        TEXT,
    c        TEXT,
    sat      DOUBLE, -- Current level of satisfaction
    base     DOUBLE, -- Baseline level of satisfaction
    nat      DOUBLE, -- Natural level of satisfaction

    PRIMARY KEY (t,g,c)
);

-- hist_sat view: includes saliency and population to allow for 
-- easy computation of rollups

CREATE VIEW hist_sat AS
SELECT HS.t          AS t,
       HS.g          AS g,
       HS.c          AS c,
       HS.sat        AS sat,
       HS.base       AS base,
       HS.nat        AS nat,
       U.saliency    AS saliency,
       HC.population AS population
FROM hist_sat_raw AS HS
JOIN uram_sat  AS U  USING (g,c)
JOIN hist_civg AS HC USING (t,g);

CREATE TABLE hist_coop (
    -- History: coop.f.g
    t        INTEGER,
    f        TEXT,
    g        TEXT,
    coop     DOUBLE, -- Current level of cooperation
    base     DOUBLE, -- Baseline level of cooperation
    nat      DOUBLE, -- Natural level of cooperation

    PRIMARY KEY (t,f,g)
);

CREATE TABLE hist_hrel (
    -- History: hrel.f.g
    t        INTEGER,
    f        TEXT,    -- First group
    g        TEXT,    -- Second group
    hrel     REAL,    -- Horizontal relationship of f with g.
    base     REAL,    -- Base Horizontal relationship of f with g.
    nat      REAL,    -- Natural Horizontal relationship of f with g.

    PRIMARY KEY (t,f,g)
);

CREATE TABLE hist_vrel (
    -- History: vrel.g.a
    t        INTEGER,
    g        TEXT,    -- Civilian group
    a        TEXT,    -- Actor
    vrel     REAL,    -- Vertical relationship of g with a.
    base     REAL,    -- Base Vertical relationship of g with a.
    nat      REAL,    -- Natural Vertical relationship of g with a.

    PRIMARY KEY (t,g,a)
);

CREATE TABLE hist_nbcoop (
    -- History: nbcoop.n.g
    t        INTEGER,
    n        TEXT,
    g        TEXT,
    nbcoop   DOUBLE,

    PRIMARY KEY (t,n,g)
);

-- aam_battle

-- This table is sparse in that it only contains data for groups that
-- are actively engaged in combat at time t.  To get data from a single
-- force groups point of view see hist_amm_battle_fview below. This
-- data is saved by the AAM module

CREATE TABLE hist_aam_battle (
    t           INTEGER,
    n           TEXT,
    f           TEXT,
    g           TEXT,
    roe_f       TEXT,
    roe_g       TEXT,
    dpers_f     INTEGER,
    dpers_g     INTEGER,
    startp_f    TEXT,
    startp_g    TEXT,
    endp_f      TEXT,
    endp_g      TEXT,
    cas_f       INTEGER,
    cas_g       INTEGER,
    civc_f      TEXT,
    civc_g      TEXT,
    civcas_f    INTEGER,
    civcas_g    INTEGER,

    PRIMARY KEY(t,n,f,g)
);

-- hist_aam_battle_fview

-- This view is useful when wanting to get data for a force group
-- of interest into the same column reliably.  This view can be used 
-- with a WHERE clause on f to get just the battles some group is 
-- involved in, but always have that group appear in the column for f
-- AND all the data for where f is really in g be switched
-- appropriately

CREATE VIEW hist_aam_battle_fview AS
SELECT F.t         AS t,
       F.n         AS n,
       F.f         AS f,
       F.g         AS g,
       F.roe_f     AS roe_f,
       F.roe_g     AS roe_g,
       F.dpers_f   AS dpers_f,
       F.dpers_g   AS dpers_g,
       F.startp_f  AS startp_f,
       F.startp_g  AS startp_g,
       F.endp_f    AS endp_f,
       F.endp_g    AS endp_g,
       F.cas_f     AS cas_f,
       F.cas_g     AS cas_g,
       F.civcas_f  AS civcas_f,
       F.civcas_g  AS civcas_g,
       F.civc_f    AS civc_f,
       F.civc_g    AS civc_g
FROM hist_aam_battle AS F
UNION
SELECT G.t         AS t,
       G.n         AS n,
       G.g         AS f,
       G.f         AS g,
       G.roe_g     AS roe_f,
       G.roe_f     AS roe_g,
       G.dpers_g   AS dpers_f,
       G.dpers_f   AS dpers_g,
       G.startp_g  AS startp_f,
       G.startp_f  AS startp_g,
       G.endp_g    AS endp_f,
       G.endp_f    AS endp_g,
       G.cas_g     AS cas_f,
       G.cas_f     AS cas_g,
       G.civcas_g  AS civcas_f,
       G.civcas_f  AS civcas_g,
       G.civc_g    AS civc_f,
       G.civc_f    AS civc_g
FROM hist_aam_battle AS G;

-- econ
CREATE TABLE hist_econ (
    t           INTEGER,
    consumers   INTEGER,
    subsisters  INTEGER,
    labor       INTEGER,
    lsf         DOUBLE,
    csf         DOUBLE,
    rem         DOUBLE,
    cpi         DOUBLE,
    dgdp        DOUBLE,
    agdp        DOUBLE,
    ur          DOUBLE,

    PRIMARY KEY (t)
);

-- econ.i
CREATE TABLE hist_econ_i (
    t           INTEGER,
    i           TEXT,
    p           DOUBLE,
    qs          DOUBLE,
    rev         DOUBLE,

    PRIMARY KEY (t,i)
);

-- econ.i.j
CREATE TABLE hist_econ_ij (
    t           INTEGER,
    i           TEXT,
    j           TEXT,
    x           DOUBLE,
    qd          DOUBLE,

    PRIMARY KEY (t,i,j)        
);

CREATE TABLE hist_plant_na (
    t           INTEGER,
    n           TEXT,
    a           TEXT,
    num         INTEGER,
    cap         DOUBLE,

    PRIMARY KEY (t,n,a)
);

CREATE VIEW hist_plant_n AS
SELECT t, n, sum(num) AS num, total(cap) AS cap
FROM hist_plant_na GROUP BY t,n;

CREATE VIEW hist_plant_a AS
SELECT t, a, sum(num) AS num, total(cap) AS cap
FROM hist_plant_na GROUP BY t,a;

-- support.n.a
CREATE TABLE hist_support (
    t              INTEGER,
    n              TEXT,    -- Neighborhood
    a              TEXT,    -- Actor
    direct_support REAL,    -- a's direct support in n
    support        REAL,    -- a's total support (direct + derived) in n
    influence      REAL,    -- a's influence in n

    PRIMARY KEY (t,n,a)
);

CREATE TABLE hist_flow (
    -- History: flow.f.g (population flow from f to g)
    -- This table is sparse; only positive flows are included.
    -- Unlike the other tables, it is not saved by [hist], but
    -- by [demog].
    t       INTEGER,
    f       TEXT,
    g       TEXT,
    flow    INTEGER DEFAULT 0,
    
    PRIMARY KEY (t,f,g)
);

CREATE TABLE hist_service_sg (
    -- History: service.sg (amount of service s to group g)

    t INTEGER,
    s TEXT,
    g TEXT,
    saturation_funding REAL,
    required           REAL,
    funding            REAL,
    actual             REAL,
    expected           REAL,
    expectf            REAL,
    needs              REAL,

    PRIMARY KEY (t,s,g)
);

CREATE TABLE hist_activity_nga (
    -- History: activity.nga (activity by nbhood and group)

    t        INTEGER,
    n        TEXT,
    g        TEXT,
    a        TEXT,
    security_flag INTEGER,
    can_do        INTEGER,
    nominal       INTEGER,
    effective     INTEGER,
    coverage      DOUBLE,
    
    PRIMARY KEY (t,n,g,a)
);


------------------------------------------------------------------------
-- End of File
------------------------------------------------------------------------
