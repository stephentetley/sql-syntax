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
    use Text.PrettyPrint.{<<>>, <^>, empty, text, parens, intersperse, comma, space, tupled}

    use SqlSyntax.Datatypes.{Expr, Statement, CreateTableStmt, ColumnSpec, ColumnConstraint, SqlType, QualifiedTableName}
    use SqlSyntax.Datatypes.Statement.{CreateTable}
    use SqlSyntax.Datatypes.CreateTableStmt.{CreateTableStmt}
    use SqlSyntax.Datatypes.QualifiedTableName.{QualifiedTableName, UnqualifiedTableName}
    use SqlSyntax.Datatypes.ColumnSpec.{Column, GeneratedColumn}
    use SqlSyntax.Datatypes.ColumnConstraint.{PrimaryKey, AllowNull, Unique, Check, Default, References, Collate}
    use SqlSyntax.Datatypes.SqlType.{Varchar, Integer}

    pub def docOrEmpty(b: Bool, d: Doc): Doc = if (b) d else empty()

    pub def ppExpr(x: Expr): Doc = match x {
        case _ => text("Expr - todo")
    }

    pub def ppStatement(x: Statement): Doc = match x {
        case CreateTable(stmt) => ppCreateTableStmt(stmt)
    }

    pub def ppCreateTableStmt(x: CreateTableStmt): Doc = match x {
        case CreateTableStmt(orRepB, tempB, notExistsB, qname, cols, pks) => 
            let orReplace = docOrEmpty(orRepB, text("OR REPLACE"));
            let temporary = docOrEmpty(tempB, text("TEMPORARY"));
            let ifNotExists = docOrEmpty(notExistsB, text("IF NOT EXISTS"));
            let colsD = intersperse(text(", "), List.map(match (n,ty) -> text(n) <<>> ppColumnSpec(ty), cols));
            let pkD = text("PRIMARY KEY") + parens(intersperse(text(", "), List.map(text, pks)));
            text("CREATE") <^> orReplace <^> temporary <<>> text("TABLE") <^> ifNotExists <<>> ppQualifiedTableName(qname) <<>> parens(colsD + comma() <<>> pkD) 
    }



    pub def ppQualifiedTableName(x: QualifiedTableName): Doc = match x {
        case QualifiedTableName(scm, name) => text(scm ++ "." ++ name)
        case UnqualifiedTableName(name) => text(name)
    }


    pub def ppColumnSpec(x: ColumnSpec): Doc = match x {
        case Column(ty, _constrs) => ppSqlType(ty) <<>> text("TODO")
        case GeneratedColumn(ty, _genAlwaysB) => ppSqlType(ty) <<>> text("TODO")
    }


    pub def ppColumnConstraint(x: ColumnConstraint): Doc = match x {
        case PrimaryKey             => text("PRIMARY KEY")
        case AllowNull(b)           => if (b) text("NULL") else text("NOT NULL")
        case Unique                 => text("UNIQUE")
        case Check(expr)            => text("CHECK") <<>> parens(ppExpr(expr)) 
        case Default(Left(lit))     => text("DEFAULT") <<>> ppExpr(lit)
        case Default(Right(expr))   => text("DEFAULT") <<>> parens(ppExpr(expr))
        case References(ft, names)  => text("REFERENCES") <<>> text(ft) <<>> tupled(List.map(text, names))
        case Collate(cname)         => text("COLLATE") <<>> text(cname)
    }

    pub def ppSqlType(x: SqlType): Doc = match x {
        case Varchar => text("VARCHAR")
        case Integer => text("INTEGER")
    }


}
