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

mod SqlSyntax.Datatypes {


    pub enum Expr with Eq, ToString {
        case ExprTodo
    }


    // Columns and primary keys
    pub enum Statement with Eq, ToString {
        case CreateTable(CreateTableStmt)
    }

    pub enum CreateTableStmt with Eq, ToString {
        case CreateTableStmt(OrReplaceB, TemporaryB, IfNotExistsB, QualifiedTableName, List[(String, ColumnSpec)], List[TableConstraint])
    }

    pub type alias OrReplaceB = Bool
    pub type alias TemporaryB = Bool
    pub type alias IfNotExistsB = Bool


    pub enum QualifiedTableName with Eq, ToString {
        case QualifiedTableName(String, String)
        case UnqualifiedTableName(String)
    }


    pub enum ColumnSpec with Eq, ToString {
        case Column(SqlType, List[ColumnConstraint])
        case GeneratedColumn(SqlType, GeneratedAlwaysB)
    }

    pub type alias GeneratedAlwaysB = Bool

    pub enum ColumnConstraint with Eq, ToString {
        case PrimaryKeyCC
        case AllowNullCC(Bool)
        case UniqueCC
        case CheckCC(Expr)
        case DefaultCC(Either[Expr, Expr])      // TODO left should be literal
        case ReferencesCC(String, List[String])
        case CollateCC(String)
    }

    pub enum TableConstraint with Eq, ToString {
        case PrimaryKeyTC(List[String])
        case UniqueTC(List[String])
        case CheckTC(Expr)
        case ForeignKeyTC(List[String], String, List[String])
    }

    pub enum SqlType with Eq, ToString {
        case Varchar
        case Integer
    }



}
