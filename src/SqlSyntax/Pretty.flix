/*
 * Copyright 2024 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

mod SqlSyntax.Pretty {

    use Either.{Left, Right}
    use Text.PrettyPrint.Doc
    use Text.PrettyPrint.{<<>>, <^>, empty, text, parens, sep, intersperse, equals, comma, space, tupled, optionalTupled, 
        dot, char, int32, squotes, conditionalParens}

    use SqlSyntax.Datatypes.{TODO}
    use SqlSyntax.Datatypes.TODO.{TODO}

    use SqlSyntax.Datatypes.{Expression, Literal, 
        Statement, CreateTableStmt, DropStmt, ColumnSpec, ColumnConstraint, TableConstraint, 
        QualifiedName, DropQualifier, CascadeOrRestrict, 
        InsertStmt, InsertQualifier, InsertColumnQualifier, InsertValuesClause, OnConflictClause, DoUpdateOrDoNothing, ReturningClause, 
        SelectStmt, SelectClause, DistinctClause, SelectExpr, StarOptions, ColumnExpression,
        ValuesClause, FromClause, FromExpressionOrJoin, FromExpression, JoinClause, 
        TableOrSubquery, JoinDesignation, JoinCondition, NaturalOrAsOf, JoinType, OuterJoin, 
        TableAlias, TableSample, 
        PercentOrRowCount, SamplingMethod, 
        WhereClause, 
        GroupByClause, Grouping, CubeOrRollup, 
        HavingClause, 
        WindowClause, WindowDefinition, PartitionByClause, FrameSpec, RangeOrRows, FrameBody, FrameStart, FrameStop, WindowExclude,
        QualifyClause, OrderByClause, LimitClause, 
        SqlType}
    use SqlSyntax.Datatypes.QualifiedName.{QualifiedName, UnqualifiedName}
    use SqlSyntax.Datatypes.Expression.{Literal}
    use SqlSyntax.Datatypes.Literal.{Integer, Varchar}
    use SqlSyntax.Datatypes.Statement.{CreateTable, Drop, Insert, Select}
    use SqlSyntax.Datatypes.CreateTableStmt.{CreateTableStmt}
    use SqlSyntax.Datatypes.ColumnSpec.{Column, GeneratedColumn}
    use SqlSyntax.Datatypes.ColumnConstraint.{PrimaryKeyCC, AllowNullCC, UniqueCC, CheckCC, DefaultCC, ReferencesCC, CollateCC}
    use SqlSyntax.Datatypes.TableConstraint.{PrimaryKeyTC, UniqueTC, CheckTC, ForeignKeyTC}
    use SqlSyntax.Datatypes.DropStmt.{DropStmt}
    use SqlSyntax.Datatypes.DropQualifier.{FunctionDQ, IndexDQ, MacroDQ, SchemaDQ, SequenceDQ, TableDQ, ViewDQ, TypeDQ}
    use SqlSyntax.Datatypes.CascadeOrRestrict.{CascadeCR, RestrictCR}
    use SqlSyntax.Datatypes.InsertStmt.{InsertStmt}
    use SqlSyntax.Datatypes.InsertQualifier.{OrReplaceIQ, OrIgnoreIQ}
    use SqlSyntax.Datatypes.InsertColumnQualifier.{ByPositionICQ, ByNameICQ}
    use SqlSyntax.Datatypes.InsertValuesClause.{ValuesIVC, SelectIVC, DefaultValuesIVC}
    use SqlSyntax.Datatypes.ValuesClause.{ValuesClause}
    use SqlSyntax.Datatypes.ReturningClause.{ReturningClause}
    use SqlSyntax.Datatypes.OnConflictClause.{OnConflictClause}
    use SqlSyntax.Datatypes.DoUpdateOrDoNothing.{DoUpdate, DoNothing}
    use SqlSyntax.Datatypes.SelectStmt.{SelectStmt}
    use SqlSyntax.Datatypes.SelectClause.{SelectClause}
    use SqlSyntax.Datatypes.DistinctClause.{Distinct, All}
    use SqlSyntax.Datatypes.SelectExpr.{SelectExpr, SelectStar, SelectColumns}
    use SqlSyntax.Datatypes.StarOptions.{StarOptions}
    use SqlSyntax.Datatypes.ColumnExpression.{ColumnStar, ColumnRegex, ColumnLambda}
    use SqlSyntax.Datatypes.FromClause.{FromClause}
    use SqlSyntax.Datatypes.FromExpressionOrJoin.{FromExpression, JoinExpression}
    use SqlSyntax.Datatypes.FromExpression.{TableReference, TableFunction, Subquery, Values}
    use SqlSyntax.Datatypes.JoinClause.{JoinClause}
    use SqlSyntax.Datatypes.TableOrSubquery.{Table, Subquery}
    use SqlSyntax.Datatypes.JoinDesignation.{Join, Positional, Cross}
    use SqlSyntax.Datatypes.JoinCondition.{On, Using}
    use SqlSyntax.Datatypes.NaturalOrAsOf.{Natural, AsOf}
    use SqlSyntax.Datatypes.JoinType.{InnerJoin, LeftJoin, RightJoin, FullJoin}
    use SqlSyntax.Datatypes.OuterJoin.{OuterJoin}
    use SqlSyntax.Datatypes.TableAlias.{TableAlias}
    use SqlSyntax.Datatypes.TableSample.{SizeFirst, FunctionStyle}
    use SqlSyntax.Datatypes.PercentOrRowCount.{Percent, RowCount}
    use SqlSyntax.Datatypes.SamplingMethod.{Reservoir, Bernoulli, System}
    use SqlSyntax.Datatypes.WhereClause.{WhereClause}
    use SqlSyntax.Datatypes.GroupByClause.{GroupBy, GroupByAll}
    use SqlSyntax.Datatypes.Grouping.{GroupingExpr, GroupingSets, GroupingSimple}
    use SqlSyntax.Datatypes.CubeOrRollup.{Cube, Rollup}
    use SqlSyntax.Datatypes.HavingClause.{HavingClause}
    use SqlSyntax.Datatypes.WindowClause.{WindowClause}
    use SqlSyntax.Datatypes.WindowDefinition.{WindowDefinition}
    use SqlSyntax.Datatypes.PartitionByClause.{PartitionByClause}
    use SqlSyntax.Datatypes.FrameSpec.{FrameSpec}
    use SqlSyntax.Datatypes.RangeOrRows.{Range, Rows}
    // use SqlSyntax.Datatypes.FrameBody.{Between, UnboundedPreceding, Preceding, CurrentRow}
    // use SqlSyntax.Datatypes.FrameStart.{UnboundedPreceding, Preceding, CurrentRow, Following}
    use SqlSyntax.Datatypes.FrameStop.{Preceding, CurrentRow, Following, UnboundedFollowing}
    use SqlSyntax.Datatypes.WindowExclude.{CurrentRow, Group, Ties, NoOthers}
    use SqlSyntax.Datatypes.QualifyClause.{QualifyClause}
    use SqlSyntax.Datatypes.OrderByClause.{OrderByExprs, OrderByAll}
    use SqlSyntax.Datatypes.LimitClause.{LimitClause}
    use SqlSyntax.Datatypes.SqlType.{VarcharType, IntegerType}


    // TEMP - add to flix-pretty?
    // def optionalIntersperse(sepd: Doc, docs: List[Doc]): Doc = match Text.PrettyPrint.removeEmpties(docs) {
    //     case Nil => empty()
    //     case xs  => intersperse(sepd, xs)
    // }

    /// TEMP - add to flix-pretty - need to check the operator intersperse uses instead of manually adding a space (", ")
    def commaSpaceSep(docs: List[Doc]): Doc = intersperse(text(", "), docs)


    def docOrEmpty(b: Bool, d: Doc): Doc = if (b) d else empty()

    def someOrEmpty(x: Option[a], f: a -> Doc): Doc = match x { 
        case Some(a) => f(a)
        case None => empty()
    }

    def ppTODO(x: TODO): Doc = match x {
        case TODO(name) => text("TODO:") <<>> text(name)
    }

    pub def ppQualifiedName(x: QualifiedName): Doc = match x {
        case QualifiedName(scm, name) => text(scm ++ "." ++ name)
        case UnqualifiedName(name)    => text(name)
    }


    pub def ppExpression(x: Expression): Doc = match x {
        case Literal(lit) => ppLiteral(lit)
    }

    pub def ppStatement(x: Statement): Doc = match x {
        case CreateTable(stmt)  => ppCreateTableStmt(stmt)
        case Drop(stmt)         => ppDropStmt(stmt)
        case Insert(stmt)       => ppInsertStmt(stmt)
        case Select(stmt)      => ppSelectStmt(stmt)
    }

    pub def ppCreateTableStmt(x: CreateTableStmt): Doc = match x {
        case CreateTableStmt(orRepB, tempB, notExistsB, qname, cols, tblConstrs) => 
            let orReplace = docOrEmpty(orRepB, text("OR REPLACE"));
            let temporary = docOrEmpty(tempB, text("TEMPORARY"));
            let ifNotExists = docOrEmpty(notExistsB, text("IF NOT EXISTS"));
            let colsDs = List.map(match (n,ty) -> text(n) <<>> ppColumnSpec(ty), cols);
            let tblConstrsD = sep(List.map(ppTableConstraint, tblConstrs));
            text("CREATE") <^> orReplace <^> temporary <<>> text("TABLE") <^> ifNotExists <<>> ppQualifiedName(qname) 
                <<>> optionalTupled(colsDs ++ List#{tblConstrsD})
    }

    def ppColumnSpec(x: ColumnSpec): Doc = match x {
        case Column(ty, constrs)              => ppSqlType(ty) <^> ppColumnConstraints(constrs)
        case GeneratedColumn(optType, _, _, _) => {
            let sqltype = someOrEmpty(optType, ppSqlType);
            sqltype <^> text("TODO")
        }
    }

    def ppColumnConstraints(xs: List[ColumnConstraint]): Doc = 
        intersperse(space(), List.map(ppColumnConstraint, xs))

    def ppColumnConstraint(x: ColumnConstraint): Doc = match x {
        case PrimaryKeyCC               => text("PRIMARY KEY")
        case AllowNullCC(b)             => if (b) text("NULL") else text("NOT NULL")
        case UniqueCC                   => text("UNIQUE")
        case CheckCC(expr)              => text("CHECK") <<>> parens(ppExpression(expr)) 
        case DefaultCC(Left(lit))       => text("DEFAULT") <<>> ppLiteral(lit)
        case DefaultCC(Right(expr))     => text("DEFAULT") <<>> parens(ppExpression(expr))
        case ReferencesCC(ft, names)    => text("REFERENCES") <<>> text(ft) <<>> tupled(List.map(text, names))
        case CollateCC(cname)           => text("COLLATE") <<>> text(cname)
    }

    def ppTableConstraint(x: TableConstraint): Doc = match x {
        case PrimaryKeyTC(cols)             => text("PRIMARY KEY") <<>> tupled(List.map(text, cols))
        case UniqueTC(cols)                 => text("UNIQUE") <<>> tupled(List.map(text, cols))
        case CheckTC(expr)                  => text("CHECK") <<>> parens(ppExpression(expr)) 
        case ForeignKeyTC(cols, ft, fcols)  => 
            text("FOREIGN KEY") <<>> tupled(List.map(text, cols)) <<>> text("REFERENCES") <<>> text(ft) <<>> tupled(List.map(text, fcols))
    }


    pub def ppDropStmt(x: DropStmt): Doc = match x {
        case DropStmt(tyqual, ifExistsB, qname, optCascadeRestrict) => 
            let ifExists = docOrEmpty(ifExistsB, text("IF EXISTS"));
            let cascadeRestrict = someOrEmpty(optCascadeRestrict, ppCascadeOrRestrict);
            text("DROP") <<>> ppDropQualifier(tyqual) <^> ifExists <<>> ppQualifiedName(qname) <^> cascadeRestrict
    }

    def ppDropQualifier(x: DropQualifier): Doc = match x {
        case FunctionDQ => text("FUNCTION")
        case IndexDQ    => text("SEQUENCE")
        case MacroDQ(b) => text("MACRO") <^> docOrEmpty(b, text("TABLE"))
        case SchemaDQ   => text("SCHEMA")
        case SequenceDQ => text("SEQUENCE")
        case TableDQ    => text("TABLE")
        case ViewDQ     => text("VIEW")
        case TypeDQ     => text("TYPE")
    }
    
    def ppCascadeOrRestrict(x: CascadeOrRestrict): Doc = match x {
        case CascadeCR  => text("CASCADE")
        case RestrictCR => text("RESTRICT")
    }

    pub def ppInsertStmt(x:  InsertStmt): Doc = match x {
        case InsertStmt(optInsQual, qname, optAsName, cols, optColQual, valClause, ocClause, optRetClause) => 
            let insQual = someOrEmpty(optInsQual, ppInsertQualifier);
            let asName = someOrEmpty(optAsName, name -> text("AS") <<>> ppQualifiedName(name));
            let colsD = optionalTupled(List.map(text, cols));
            let colQual = someOrEmpty(optColQual, ppInsertColumnQualifier);
            let onConflict = someOrEmpty(ocClause, ppOnConflictClause);
            let retClause = someOrEmpty(optRetClause, ppInsertReturningClause);
            text("INSERT") <^> insQual <<>> text("INTO") 
                <<>> ppQualifiedName(qname) 
                <^> asName 
                <^> colsD <^> colQual
                <<>> ppInsertValuesClause(valClause)
                <^> onConflict
                <^> retClause
    }

    def ppInsertQualifier(x: InsertQualifier): Doc = match x {
        case OrReplaceIQ    => text("OR REPLACE")
        case OrIgnoreIQ     => text("OR IGNORE")
    }

    def ppInsertColumnQualifier(x: InsertColumnQualifier): Doc = match x {
        case ByPositionICQ  => text("BY POSITION")
        case ByNameICQ      => text("BY NAME")
    }


    def ppInsertValuesClause(x: InsertValuesClause): Doc = match x {
        case ValuesIVC(vals)    => ppValuesClause(vals)
        case SelectIVC(selStmt) => ppSelectStmt(selStmt)
        case DefaultValuesIVC   => text("DEFAULT VALUES")
    }

    def ppValuesClause(x: ValuesClause): Doc = match x {
        case ValuesClause(xss)     => {
            let ppValuesList = xs -> optionalTupled(List.map(ppExpression, xs));
            text("VALUES") <<>> commaSpaceSep(List.map(ppValuesList, xss))
        }
    }

    def ppOnConflictClause(x: OnConflictClause): Doc = match x {
        case OnConflictClause(cols, optWhereExpr, dudn) => {
            let columns = optionalTupled(List.map(text, cols));
            let whereExpr = someOrEmpty(optWhereExpr, expr -> text("WHERE") <<>> ppExpression(expr));
            text("ON CONFLICT") <^> columns <^> whereExpr <<>> ppDoUpdateOrDoNothing(dudn)
        }
    }


    def ppDoUpdateOrDoNothing(x: DoUpdateOrDoNothing): Doc = match x {
        case DoUpdate(setExprs, optWhereExpr) => {
            let setCols = commaSpaceSep(List.map(match (col, expr) -> text(col) <<>> equals() <<>> ppExpression(expr), setExprs));
            let whereExpr = someOrEmpty(optWhereExpr, expr -> text("WHERE") <<>> ppExpression(expr));
            text("DO UPDATE") <<>> text("SET") <<>> setCols <^> whereExpr
        }
        case DoNothing => text("DO NOTHING")
    }

    def ppInsertReturningClause(x: ReturningClause): Doc = match x {
        case ReturningClause(starB, retExprs) => 
            let star = docOrEmpty(starB, text("*"));
            text("RETURNING") <<>> commaSpaceSep(star :: List.map(ppReturnExpression, retExprs))
    }

    def ppReturnExpression(x: (Expression, Option[(Bool, String)])): Doc = match x {
        case (expr, None) => ppExpression(expr)
        case (expr, Some(b, exprAlias)) => ppExpression(expr) <^> docOrEmpty(b, text("AS")) <<>> text(exprAlias)
    }



    pub def ppSelectStmt(x: SelectStmt): Doc = match x {
        case SelectStmt(selClause, fromClause, optWhere, optGroupBy, optHaving, optWindow, optQualify, optOrderBy, optLimit) => {
            ppSelectClause(selClause) 
                <<>> ppFromClause(fromClause) 
                <^> someOrEmpty(optWhere, ppWhereClause)
                <^> someOrEmpty(optGroupBy, ppGroupByClause)
                <^> someOrEmpty(optHaving, ppHavingClause)
                <^> someOrEmpty(optWindow, ppWindowClause)
                <^> someOrEmpty(optQualify, ppQualifyClause)
                <^> someOrEmpty(optOrderBy, ppOrderByClause)
                <^> someOrEmpty(optLimit, ppLimitClause)
        }
    }

    def ppSelectClause(x: SelectClause): Doc = match x {
        case SelectClause(optDistinct, sels) => {
            let distinct = someOrEmpty(optDistinct, ppDistinctClause);
            let selectExprs = commaSpaceSep(List.map(ppSelectExpr, sels));
            text("SELECT") <^> distinct <<>> selectExprs
        }
    }

    def ppDistinctClause(x: DistinctClause): Doc = match x {
        case Distinct(None)         => text("DISTINCT")
        case Distinct(Some(exprs))  => text("DISTINCT") <<>> text("ON") <<>> tupled(List.map(ppExpression, exprs))
        case All                    => text("ALL")
    }

    def ppSelectExpr(x: SelectExpr): Doc = match x {
        case SelectExpr(expr, None) => ppExpression(expr) 
        case SelectExpr(expr, Some(asB, nameAlias)) => 
            ppExpression(expr) <^> docOrEmpty(asB, text("AS")) <<>> text(nameAlias)
        case SelectStar(optTable, starOpts) => {
            let tableName = someOrEmpty(optTable, s -> text(s) ++ dot());
            tableName <^> char('*') <<>> ppStarOptions(starOpts)
        }
        case SelectColumns(colExpr) => text("COLUMNS") <<>> parens(ppColumnExpression(colExpr))
        
    }

    def ppStarOptions(x: StarOptions): Doc = match x {
        case StarOptions(optExcludes, optReplaces) => {
            let excludes = someOrEmpty(optExcludes, xs -> text("EXCLUDE") <<>> tupled(List.map(text, xs)));
            let makeReplace = match (expr, name) -> ppExpression(expr) <<>> text("AS" ) <<>> text(name); 
            let replaces = someOrEmpty(optReplaces, xs -> text("REPLACE") <<>> tupled(List.map(makeReplace, xs)));
            excludes <^> replaces
        }
    }

    def ppColumnExpression(x: ColumnExpression): Doc = match x {
        case ColumnStar(optTable, starOpts) => {
            let tableName = someOrEmpty(optTable, s -> text(s) ++ dot());
            tableName <^> char('*') <<>> ppStarOptions(starOpts)
        }
        case ColumnRegex(regex) => squotes(text(regex))
        case ColumnLambda(todo) => ppTODO(todo)
    }

    def ppFromClause(x: FromClause): Doc = match x {
        case FromClause(exprs) => { 
            let exprList = commaSpaceSep(List.map(ppFromExpressionOrJoin, exprs));
            text("FROM") <<>> exprList
        }
    }

    def ppFromExpressionOrJoin(x: FromExpressionOrJoin): Doc = match x {
        case FromExpression(expr, optAlias, optSample) => {
            let tableAlias = someOrEmpty(optAlias, ppTableAlias);
            let sample = someOrEmpty(optSample, ppTableSample);
            ppFromExpression(expr) <^> tableAlias <^> sample
        }
        case JoinExpression(parensB, joinClause, optAlias) => {
            let joinAlias = someOrEmpty(optAlias, s -> text("AS") <<>> text(s));
            conditionalParens(parensB, ppJoinClause(joinClause) <^> joinAlias)
        }
    }

    def ppFromExpression(x: FromExpression): Doc = match x {
        case TableReference(qname)          => ppQualifiedName(qname)
        case TableFunction(qname, exprs)    => ppQualifiedName(qname) ++ tupled(List.map(ppExpression, exprs))
        case FromExpression.Subquery(stmt)  => parens(ppSelectStmt(stmt))
        case Values(valsClause)             => parens(ppValuesClause(valsClause))
    }

    def ppJoinClause(x: JoinClause): Doc = match x { 
        case JoinClause(tableA, optJoinDes, tableB, optJoinCond) => {
            let designator = someOrEmpty(optJoinDes, ppJoinDesignation);
            let joinCondition = someOrEmpty(optJoinCond, ppJoinCondition);
            ppTableOrSubquery(tableA) <^> designator <<>> text("JOIN") <<>> ppTableOrSubquery(tableB) <^> joinCondition
        }
    }

    def ppTableOrSubquery(x: TableOrSubquery): Doc = match x { 
        case Table(name)    => text(name)
        case Subquery(stmt) => ppSelectStmt(stmt)
    }


    def ppJoinDesignation(x: JoinDesignation): Doc = match x { 
        case Join(optNatAsof, joinType) => someOrEmpty(optNatAsof, ppNaturalOrAsOf) <^> ppJoinType(joinType)
        case Positional => text("POSITIONAL")
        case Cross      => text("CROSS")
    }

    def ppJoinCondition(x: JoinCondition): Doc = match x { 
        case On(expr)       => text("ON") <<>> ppExpression(expr)
        case Using(cols)    => text("USING") <<>> tupled(List.map(text, cols))
    }

    def ppNaturalOrAsOf(x: NaturalOrAsOf): Doc = match x { 
        case Natural    => text("NATURAL")
        case AsOf       => text("ASOF")
    }

    def ppJoinType(x: JoinType): Doc = match x { 
        case InnerJoin      => text("OUTER")
        case LeftJoin(opt)  => text("LEFT") <^> someOrEmpty(opt, ppOuterJoin)
        case RightJoin(opt) => text("RIGHT") <^> someOrEmpty(opt, ppOuterJoin)
        case FullJoin(opt)  => text("FULL") <^> someOrEmpty(opt, ppOuterJoin)
    }

    def ppOuterJoin(x: OuterJoin): Doc = match x { 
        case OuterJoin => text("OUTER")
    }

    def ppTableAlias(x: TableAlias): Doc = match x {
        case TableAlias(asB, tableAlias, optCols) => 
        let asKwd = docOrEmpty(asB, text("AS"));
        let columns = someOrEmpty(optCols, cols -> optionalTupled(List.map(text, cols)));
        asKwd <^> text(tableAlias) <^> columns
    }

    def ppTableSample(x: TableSample): Doc = match x { 
        case SizeFirst(sz, optUnit, optMethod) => {
            let sampleUnit = someOrEmpty(optUnit, ppPercentOrRowCount);
            let sampleMethod = someOrEmpty(optMethod, 
                match (s, optCount) -> parens(ppSamplingMethod(s) <^> someOrEmpty(optCount, i -> comma() <<>> int32(i))));
            int32(sz) <^> sampleUnit <^> sampleMethod
        }
        case FunctionStyle(optMethod, sz, optUnit, optSeed) => {
            let sampleMethod = someOrEmpty(optMethod, ppSamplingMethod);
            let sampleUnit = someOrEmpty(optUnit, ppPercentOrRowCount);
            let seed = someOrEmpty(optSeed, i -> text("REPEATABLE") <<>> parens(int32(i)));
            sampleMethod <^> parens(int32(sz) <^> sampleUnit) <^> seed
        }
    }


    def ppPercentOrRowCount(x: PercentOrRowCount): Doc = match x {
        case Percent(b) => if (b) char('%') else text("PERCENT")
        case RowCount   => text("ROWS")
    }

    def ppSamplingMethod(x: SamplingMethod): Doc = match x {
        case Reservoir  => text("reservoir")
        case Bernoulli  => text("bernoulli")
        case System     => text("system")
    }


    def ppWhereClause(x: WhereClause): Doc = match x {
        case WhereClause(expr) => text("WHERE") <<>> ppExpression(expr)
    }


    def ppGroupByClause(x: GroupByClause): Doc = match x {
        case GroupBy(xs)    => text("GROUP BY") <<>> commaSpaceSep(List.map(ppGrouping, xs))
        case GroupByAll     => text("GROUP BY") <<>> text("ALL")
    }

    def ppGrouping(x: Grouping): Doc = match x {
        case GroupingExpr(expr) => ppExpression(expr)
        case GroupingSets(xss)  => tupled(List.map(tupled, List.map(List.map(ppExpression), xss)))
        case GroupingSimple(cor, exprs) => ppCubeOrRollup(cor) <<>> tupled(List.map(ppExpression, exprs))
    }

    def ppCubeOrRollup(x: CubeOrRollup): Doc = match x {
        case Cube   => text("CUBE")
        case Rollup => text("ROLLUP")
    }

    def ppHavingClause(x: HavingClause): Doc = match x {
        case HavingClause(expr) => text("HAVING") <<>> ppExpression(expr)
    }

    def ppWindowClause(x: WindowClause): Doc = match x {
        case WindowClause(winDecls) => {
            let makeWindowDecl = match (name, defn) -> text(name) <<>> text("AS") <<>> ppWindowDefinition(defn);
            text("WINDOW") <<>> commaSpaceSep(List.map(makeWindowDecl, winDecls))
        }
    }

    def ppWindowDefinition(x: WindowDefinition): Doc = match x {
        case WindowDefinition(optBaseName, optPartitionBy, optOrderBy, frameSpec) => {
            let baseName = someOrEmpty(optBaseName, text);
            let partitionBy = someOrEmpty(optPartitionBy, ppPartitionByClause);
            let orderBy = someOrEmpty(optOrderBy, ppOrderByClause);
            parens(baseName <^> partitionBy <^> orderBy <<>> ppFrameSpec(frameSpec))
        }

    }

    def ppPartitionByClause(x: PartitionByClause): Doc = match x {
        case PartitionByClause(exprs) => text("PARTITION BY") <<>> commaSpaceSep(List.map(ppExpression, exprs))
    }

    def ppFrameSpec(x: FrameSpec): Doc = match x {
        case FrameSpec(ror, frameBody, optExclude) => {
            let exclude = someOrEmpty(optExclude, ppWindowExclude);
            ppRangeOrRows(ror) <<>> ppFrameBody(frameBody) <^> exclude
        }
    }

    def ppRangeOrRows(x: RangeOrRows): Doc = match x {
        case Range  => text("RANGE")
        case Rows   => text("ROWS")
    }

    def ppFrameBody(x: FrameBody): Doc = match x {
        case FrameBody.Between(frameStart, frameStop) => 
            text("BETWEEN") <<>> ppFrameStart(frameStart) <<>> text("AND") <<>> ppFrameStop(frameStop) 
        case FrameBody.UnboundedPreceding             => text("UNBOUNDED PRECEDING")
        case FrameBody.Preceding(expr)                => ppExpression(expr) <<>> text("PRECEDING")
        case FrameBody.CurrentRow                     => text("CURRENT ROW")
    }


    def ppFrameStart(x: FrameStart): Doc = match x {
        case FrameStart.UnboundedPreceding => text("UNBOUNDED FOLLOWING")
        case FrameStart.Preceding(expr)    => ppExpression(expr) <<>> text("PRECEDING")
        case FrameStart.CurrentRow         => text("CURRENT ROW")
        case FrameStart.Following(expr)    => ppExpression(expr) <<>> text("FOLLOWING")
    }

    def ppFrameStop(x: FrameStop): Doc = match x {
        case FrameStop.Preceding(expr)    => ppExpression(expr) <<>> text("PRECEDING")
        case FrameStop.CurrentRow         => text("CURRENT ROW")
        case FrameStop.Following(expr)    => ppExpression(expr) <<>> text("FOLLOWING")
        case FrameStop.UnboundedFollowing => text("UNBOUNDED FOLLOWING")
    }

    def ppWindowExclude(x: WindowExclude): Doc = text("EXCLUDE") <<>> match x {
        case CurrentRow => text("CURRENT ROW")
        case Group      => text("GROUP")
        case Ties       => text("TIES")
        case NoOthers   => text("NO OTHERS")
    }

    def ppQualifyClause(x: QualifyClause): Doc = match x {
        case QualifyClause(expr) => text("QUALIFY") <<>> ppExpression(expr)
    }

    def ppOrderByClause(x: OrderByClause): Doc = match x {
        case OrderByExprs(_xs) => ppTODO(TODO("OrderByExprs"))
        case OrderByAll(_optSortOrder, _optNullsPos) => ppTODO(TODO("OrderByAll"))
    }

    def ppLimitClause(x: LimitClause): Doc = match x {
        case LimitClause(expr, optOffset) => {
            let offset = someOrEmpty(optOffset, expr1 -> text("OFFSET") <<>> ppExpression(expr1));
            text("LIMIT") <<>> ppExpression(expr) <^> offset
        }
    }


    pub def ppSqlType(x: SqlType): Doc = match x {
        case VarcharType => text("VARCHAR")
        case IntegerType => text("INTEGER")
    }

    pub def ppLiteral(x: Literal): Doc = match x {
        case Integer(i) => int32(i)
        case Varchar(s) => squotes(text(s))
    }

}
