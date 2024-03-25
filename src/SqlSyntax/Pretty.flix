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

    use Text.PrettyPrint.Doc
    use Text.PrettyPrint.{<<>>, empty, text, parens, intersperse, comma, space}

    use SqlSyntax.Datatypes.{Statement, CreateTableStmt, ColumnSpec, ColumnConstraint, SqlType, QualifiedTableName}
    use SqlSyntax.Datatypes.Statement.{CreateTable}
    use SqlSyntax.Datatypes.CreateTableStmt.{CreateTableStmt}
    use SqlSyntax.Datatypes.QualifiedTableName.{QualifiedTableName, UnqualifiedTableName}
    use SqlSyntax.Datatypes.ColumnSpec.{Column, GeneratedColumn}
    use SqlSyntax.Datatypes.ColumnConstraint.{PrimaryKey, AllowNull, Unique}
    use SqlSyntax.Datatypes.SqlType.{Varchar, Integer}

    pub def ppStatement(x: Statement): Doc = match x {
        case CreateTable(stmt) => ppCreateTableStmt(stmt)
    }

    pub def ppCreateTableStmt(x: CreateTableStmt): Doc = match x {
        case CreateTableStmt(orRepB, tempB, notExistsB, qname, cols, pks) => 
            let d1 = match (orRepB, tempB) { 
                case (true, true)   => space() + text("OR REPLACE TEMPORARY")
                case (true, false)  => space() + text("OR REPLACE")
                case (false, true)  => space() + text("TEMPORARY")
                case (_, _)         => empty()
            };
            let d2 = if (notExistsB) {space() + text("IF NOT EXISTS")} else empty();
            let colsD = intersperse(text(", "), List.map(match (n,ty) -> text(n) <<>> ppColumnSpec(ty), cols));
            let pkD = text("PRIMARY KEY") + parens(intersperse(text(", "), List.map(text, pks)));
            text("CREATE") + d1 <<>> text("TABLE") + d2 <<>> ppQualifiedTableName(qname) <<>> parens(colsD + comma() <<>> pkD) 
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
        case PrimaryKey     => text("PRIMARY KEY")
        case AllowNull(b)   => if (b) text("NULL") else text("NOT NULL")
        case Unique         => text("UNIQUE")
        // more
    }

    pub def ppSqlType(x: SqlType): Doc = match x {
        case Varchar => text("VARCHAR")
        case Integer => text("INTEGER")
    }


}
