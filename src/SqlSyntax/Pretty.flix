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
        int32, squotes}

    use SqlSyntax.Datatypes.{Expression, Literal, 
        Statement, CreateTableStmt, DropStmt, ColumnSpec, ColumnConstraint, TableConstraint, 
        QualifiedName, DropQualifier, CascadeOrRestrict, 
        InsertStmt, InsertQualifier, InsertColumnQualifier, InsertValuesClause, OnConflictClause, DoUpdateOrDoNothing, ReturningClause, 
        SelectStmt, SelectClause, 
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
    use SqlSyntax.Datatypes.ReturningClause.{ReturningClause}
    use SqlSyntax.Datatypes.OnConflictClause.{OnConflictClause}
    use SqlSyntax.Datatypes.DoUpdateOrDoNothing.{DoUpdate, DoNothing}
    use SqlSyntax.Datatypes.SelectStmt.{SelectStmt}
    use SqlSyntax.Datatypes.SelectClause.{SelectClause}
    use SqlSyntax.Datatypes.SqlType.{VarcharType, IntegerType}


    // TEMP - add to flix-pretty
    def optionalIntersperse(sepd: Doc, docs: List[Doc]): Doc = match Text.PrettyPrint.removeEmpties(docs) {
        case Nil => empty()
        case xs  => intersperse(sepd, xs)
    }


    def docOrEmpty(b: Bool, d: Doc): Doc = if (b) d else empty()

    def someOrEmpty(x: Option[a], f: a -> Doc): Doc = match x { 
        case Some(a) => f(a)
        case None => empty()
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
        case Select(_stmt)      => text("Select - TODO")
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
        case GeneratedColumn(ty, _genAlwaysB) => ppSqlType(ty) <<>> text("TODO")
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
        case InsertStmt(optInsQual, qname, optAsName, cols, optColQual, valClause, optRetClause) => 
            let insQual = someOrEmpty(optInsQual, ppInsertQualifier);
            let asName = someOrEmpty(optAsName, name -> text("AS") <<>> ppQualifiedName(name));
            let colsD = optionalTupled(List.map(text, cols));
            let colQual = someOrEmpty(optColQual, ppInsertColumnQualifier);
            let retClause = someOrEmpty(optRetClause, ppInsertReturningClause);
            text("INSERT") <^> insQual <<>> text("INTO") 
                <<>> ppQualifiedName(qname) 
                <^> asName 
                <^> colsD <^> colQual
                <<>> ppInsertValuesClause(valClause)
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
        case ValuesIVC(xss, occ) => {
            let ppValuesList = xs -> optionalTupled(List.map(ppExpression, xs));
            let vals = optionalIntersperse(text(", "), List.map(ppValuesList, xss));
            vals <^> ppOnConflictClause(occ)
        }
        case SelectIVC(selStmt) => ppSelectStmt(selStmt)
        case DefaultValuesIVC(occ) => text("DEFAULT VALUES") <^> ppOnConflictClause(occ)
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
            let setCols = intersperse(text(", "), List.map(match (col, expr) -> text(col) <<>> equals() <<>> ppExpression(expr), setExprs));
            let whereExpr = someOrEmpty(optWhereExpr, expr -> text("WHERE") <<>> ppExpression(expr));
            text("DO UPDATE") <<>> text("SET") <<>> setCols <^> whereExpr
        }
        case DoNothing => text("DO NOTHING")
    }

    def ppInsertReturningClause(x: ReturningClause): Doc = match x {
        case ReturningClause(starB, retExprs) => 
            let star = docOrEmpty(starB, text("*"));
            text("RETURNING") <<>> optionalIntersperse(text(", "), star :: List.map(ppReturnExpression, retExprs))
    }

    def ppReturnExpression(x: (Expression, Option[(Bool, String)])): Doc = match x {
        case (expr, None) => ppExpression(expr)
        case (expr, Some(b, exprAlias)) => ppExpression(expr) <^> docOrEmpty(b, text("AS")) <<>> text(exprAlias)
    }



    pub def ppSelectStmt(x: SelectStmt): Doc = match x {
        case SelectStmt(selClause) => ppSelectClause(selClause)
    }

    def ppSelectClause(x: SelectClause): Doc = match x {
        case SelectClause => text("TODO")
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
