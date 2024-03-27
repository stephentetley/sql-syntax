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


    pub type alias OrReplaceB = Bool
    pub type alias TemporaryB = Bool
    pub type alias IfExistsB = Bool
    pub type alias IfNotExistsB = Bool
    pub type alias TableB = Bool
    pub type alias StarB = Bool
    pub type alias AsB = Bool
    pub type alias AsSymbolB = Bool
    pub type alias ParensB = Bool

    pub enum TODO with Eq, ToString {
        case TODO(String)
    }

    pub enum Expression with Eq, ToString {
        case Literal(Literal)
    }

    pub enum QualifiedName with Eq, ToString {
        case QualifiedName(String, String)
        case UnqualifiedName(String)
    }

    pub enum Literal with Eq, ToString {
        case Integer(Int32) // TODO
        case Varchar(String)
    }

    // Columns and primary keys
    pub enum Statement with Eq, ToString {
        case CreateTable(CreateTableStmt)
        case Drop(DropStmt)
        case Insert(InsertStmt)
        case Select(SelectStmt)
    }

    pub enum CreateTableStmt with Eq, ToString {
        case CreateTableStmt(OrReplaceB, TemporaryB, IfNotExistsB, QualifiedName, List[(String, ColumnSpec)], List[TableConstraint])
    }


    pub enum ColumnSpec with Eq, ToString {
        case Column(SqlType, List[ColumnConstraint])
        case GeneratedColumn(SqlType, TODO)
    }

    pub type alias GeneratedAlwaysB = Bool

    pub enum ColumnConstraint with Eq, ToString {
        case PrimaryKeyCC
        case AllowNullCC(Bool)
        case UniqueCC
        case CheckCC(Expression)
        case DefaultCC(Either[Literal, Expression])      // TODO left should be literal
        case ReferencesCC(String, List[String])
        case CollateCC(String)
    }

    pub enum TableConstraint with Eq, ToString {
        case PrimaryKeyTC(List[String])
        case UniqueTC(List[String])
        case CheckTC(Expression)
        case ForeignKeyTC(List[String], String, List[String])
    }


    pub enum DropStmt with Eq, ToString {
        case DropStmt(DropQualifier, IfExistsB, QualifiedName, Option[CascadeOrRestrict])
    }

    pub enum DropQualifier with Eq, ToString {
        case FunctionDQ
        case IndexDQ
        case MacroDQ(TableB)
        case SchemaDQ
        case SequenceDQ
        case TableDQ
        case ViewDQ
        case TypeDQ
    }

    pub enum CascadeOrRestrict with Eq, ToString {
        case CascadeCR
        case RestrictCR
    }


    pub enum InsertStmt with Eq, ToString {
        case InsertStmt(Option[InsertQualifier], QualifiedName, Option[QualifiedName], List[String], Option[InsertColumnQualifier], InsertValuesClause, Option[OnConflictClause], Option[ReturningClause])
    }

    pub enum InsertQualifier with Eq, ToString {
        case OrReplaceIQ
        case OrIgnoreIQ
    }

    pub enum InsertColumnQualifier with Eq, ToString {
        case ByPositionICQ
        case ByNameICQ
    }


    pub enum InsertValuesClause with Eq, ToString {
        case ValuesIVC(ValuesClause)
        case SelectIVC(SelectStmt)
        case DefaultValuesIVC
    }

    pub enum ReturningClause with Eq, ToString {
        case ReturningClause(StarB, List[(Expression, Option[(AsB, String)])])
    }

    pub enum OnConflictClause with Eq, ToString {
        case OnConflictClause(List[String], Option[Expression], DoUpdateOrDoNothing)
    }

    pub enum DoUpdateOrDoNothing with Eq, ToString {
        case DoUpdate(List[(String, Expression)], Option[Expression])
        case DoNothing
    }

    pub enum ValuesClause with Eq, ToString {
        case ValuesClause(List[List[Expression]])
    }
    pub enum SelectStmt with Eq, ToString {
        case SelectStmt(SelectClause, FromClause)
    }

    pub enum SelectClause with Eq, ToString {
        case SelectClause(Option[DistinctClause], List[SelectExpr])
    }

    pub enum DistinctClause with Eq, ToString {
        case Distinct(Option[List[Expression]])
        case All
    }

    pub enum SelectExpr with Eq, ToString {
        case SelectExpr(Expression, Option[(AsB, String)])
        case SelectStar(Option[String], StarOptions)
        case SelectColumns(ColumnExpression)
    }

    pub enum StarOptions with Eq, ToString {
        case StarOptions(Option[List[String]], Option[List[(Expression, String)]])
    }

    pub enum ColumnExpression with Eq, ToString {
        case ColumnStar(Option[String], StarOptions)
        case ColumnRegex(String)
        case ColumnLambda(TODO)
    }

    pub enum FromClause with Eq, ToString {
        case FromClause(List[FromExpressionOrJoin])
    }

    pub enum FromExpressionOrJoin with Eq, ToString {
        case FromExpression(FromExpression, Option[TableAlias], Option[TableSample])
        case JoinExpression(ParensB, JoinClause, Option[String])
    }


    pub enum FromExpression with Eq, ToString {
        case TableReference(QualifiedName)
        case TableFunction(QualifiedName, List[Expression])
        case Subquery(SelectStmt)
        case Values(ValuesClause)
    }

    pub enum JoinClause with Eq, ToString {
        case JoinClause(TODO)
    }

    pub enum TableAlias with Eq, ToString {
        case TableAlias(AsB, String, Option[List[String]])
    }

    pub enum TableSample with Eq, ToString {
        case SizeFirst(Int32, Option[PercentOrRowCount], Option[(SamplingMethod, Option[Int32])])
        case FunctionStyle(Option[SamplingMethod], Int32, Option[PercentOrRowCount], Option[Int32])
    }

    // `Precent(true)` to show as `%`
    pub enum PercentOrRowCount with Eq, ToString {
        case Percent(AsSymbolB)
        case Rows
    }

    pub enum SamplingMethod with Eq, ToString {
        case Reservoir
        case Bernoulli
        case System
    }


    pub enum SqlType with Eq, ToString {
        case VarcharType
        case IntegerType
    }



}
