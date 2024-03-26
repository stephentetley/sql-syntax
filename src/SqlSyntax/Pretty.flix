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
    use Text.PrettyPrint.{<<>>, <^>, empty, text, parens, sep, intersperse, comma, space, tupled, optionalTupled}

    use SqlSyntax.Datatypes.QualifiedName.{QualifiedName, UnqualifiedName}
    use SqlSyntax.Datatypes.{Expr, Statement, CreateTableStmt, DropStmt, ColumnSpec, ColumnConstraint, TableConstraint, 
        SqlType, QualifiedName, DropQualifier, DropClause}
    use SqlSyntax.Datatypes.Statement.{CreateTable}
    use SqlSyntax.Datatypes.CreateTableStmt.{CreateTableStmt}
    use SqlSyntax.Datatypes.DropStmt.{DropStmt}
    use SqlSyntax.Datatypes.ColumnSpec.{Column, GeneratedColumn}
    use SqlSyntax.Datatypes.ColumnConstraint.{PrimaryKeyCC, AllowNullCC, UniqueCC, CheckCC, DefaultCC, ReferencesCC, CollateCC}
    use SqlSyntax.Datatypes.TableConstraint.{PrimaryKeyTC, UniqueTC, CheckTC, ForeignKeyTC}
    use SqlSyntax.Datatypes.DropQualifier.{FunctionDQ, IndexDQ, MacroDQ, SchemaDQ, SequenceDQ, TableDQ, ViewDQ, TypeDQ}
    use SqlSyntax.Datatypes.DropClause.{CascadeDC, RestrictDC}
    use SqlSyntax.Datatypes.SqlType.{Varchar, Integer}

    def docOrEmpty(b: Bool, d: Doc): Doc = if (b) d else empty()

    def someOrEmpty(x: Option[a], f: a -> Doc): Doc = match x { 
        case Some(a) => f(a)
        case None => empty()
    }

    pub def ppQualifiedName(x: QualifiedName): Doc = match x {
        case QualifiedName(scm, name) => text(scm ++ "." ++ name)
        case UnqualifiedName(name)    => text(name)
    }


    pub def ppExpr(x: Expr): Doc = match x {
        case _ => text("Expr - todo")
    }

    pub def ppStatement(x: Statement): Doc = match x {
        case CreateTable(stmt) => ppCreateTableStmt(stmt)
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




    pub def ppColumnSpec(x: ColumnSpec): Doc = match x {
        case Column(ty, constrs)              => ppSqlType(ty) <^> ppColumnConstraints(constrs)
        case GeneratedColumn(ty, _genAlwaysB) => ppSqlType(ty) <<>> text("TODO")
    }

    pub def ppColumnConstraints(xs: List[ColumnConstraint]): Doc = 
        intersperse(space(), List.map(ppColumnConstraint, xs))

    pub def ppColumnConstraint(x: ColumnConstraint): Doc = match x {
        case PrimaryKeyCC               => text("PRIMARY KEY")
        case AllowNullCC(b)             => if (b) text("NULL") else text("NOT NULL")
        case UniqueCC                   => text("UNIQUE")
        case CheckCC(expr)              => text("CHECK") <<>> parens(ppExpr(expr)) 
        case DefaultCC(Left(lit))       => text("DEFAULT") <<>> ppExpr(lit)
        case DefaultCC(Right(expr))     => text("DEFAULT") <<>> parens(ppExpr(expr))
        case ReferencesCC(ft, names)    => text("REFERENCES") <<>> text(ft) <<>> tupled(List.map(text, names))
        case CollateCC(cname)           => text("COLLATE") <<>> text(cname)
    }

    pub def ppTableConstraint(x: TableConstraint): Doc = match x {
        case PrimaryKeyTC(cols)             => text("PRIMARY KEY") <<>> tupled(List.map(text, cols))
        case UniqueTC(cols)                 => text("UNIQUE") <<>> tupled(List.map(text, cols))
        case CheckTC(expr)                  => text("CHECK") <<>> parens(ppExpr(expr)) 
        case ForeignKeyTC(cols, ft, fcols)  => 
            text("FOREIGN KEY") <<>> tupled(List.map(text, cols)) <<>> text("REFERENCES") <<>> text(ft) <<>> tupled(List.map(text, fcols))
    }


    pub def ppDropStmt(x: DropStmt): Doc = match x {
        case DropStmt(tyqual, ifExistsB, qname, optDc) => 
            let ifExistsD = docOrEmpty(ifExistsB, text("IF EXISTS"));
            let dcD = someOrEmpty(optDc, ppDropClause);
            text("DROP") <<>> ppDropQualifier(tyqual) <^> ifExistsD <<>> ppQualifiedName(qname) <^> dcD
    }

    pub def ppDropQualifier(x: DropQualifier): Doc = match x {
        case FunctionDQ => text("FUNCTION")
        case IndexDQ    => text("SEQUENCE")
        case MacroDQ(b) => text("MACRO") <^> docOrEmpty(b, text("TABLE"))
        case SchemaDQ   => text("SCHEMA")
        case SequenceDQ => text("SEQUENCE")
        case TableDQ    => text("TABLE")
        case ViewDQ     => text("VIEW")
        case TypeDQ     => text("TYPE")
    }
    
    pub def ppDropClause(x: DropClause): Doc = match x {
        case CascadeDC  => text("CASCADE")
        case RestrictDC => text("RESTRICT")
    }

    pub def ppSqlType(x: SqlType): Doc = match x {
        case Varchar => text("VARCHAR")
        case Integer => text("INTEGER")
    }


}
