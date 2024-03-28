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


    pub enum Expression with Eq, ToString {
        case Identifier(String)
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
        case GeneratedColumn(GeneratedColumn)
    }

    pub enum GeneratedColumn with Eq, ToString {
        case GeneratedColumn(Option[SqlType], Option[GeneratedAlways], Expression, Option[VirtualOrStored])
    }

    pub enum GeneratedAlways with Eq, ToString {
        case GeneratedAlways
    }

    pub enum VirtualOrStored with Eq, ToString {
        case Virtual
        case Stored
    }

    pub enum ColumnConstraint with Eq, ToString {
        case PrimaryKey
        case AllowNull(Bool)
        case Unique
        case Check(Expression)
        case Default(Either[Literal, Expression])      // TODO left should be literal
        case References(String, List[String])
        case Collate(String)
    }

    pub enum TableConstraint with Eq, ToString {
        case PrimaryKey(List[String])
        case Unique(List[String])
        case Check(Expression)
        case ForeignKey(List[String], String, List[String])
    }


    pub enum DropStmt with Eq, ToString {
        case DropStmt(DropQualifier, IfExistsB, QualifiedName, Option[CascadeOrRestrict])
    }

    pub enum DropQualifier with Eq, ToString {
        case Function
        case Index
        case Macro(TableB)
        case Schema
        case Sequence
        case Table
        case View
        case Type
    }

    pub enum CascadeOrRestrict with Eq, ToString {
        case Cascade
        case Restrict
    }


    pub enum InsertStmt with Eq, ToString {
        case InsertStmt(Option[InsertQualifier], QualifiedName, Option[QualifiedName], List[String], Option[InsertColumnQualifier], InsertValuesClause, Option[OnConflictClause], Option[ReturningClause])
    }

    pub enum InsertQualifier with Eq, ToString {
        case OrReplace
        case OrIgnore
    }

    pub enum InsertColumnQualifier with Eq, ToString {
        case ByPosition
        case ByName
    }


    pub enum InsertValuesClause with Eq, ToString {
        case Values(ValuesClause)
        case Select(SelectStmt)
        case DefaultValues
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
        case SelectStmt(SelectClause, FromClause, Option[WhereClause], Option[GroupByClause], Option[HavingClause], Option[WindowClause], Option[QualifyClause], Option[OrderByClause], Option[LimitClause])
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
        case ColumnLambda(String, LambdaFilter)
    }

    pub enum LambdaFilter with Eq, ToString {
        case LambdaFilter(Expression)
    }

    pub enum FromClause with Eq, ToString {
        case FromClause(List[FromExpressionOrJoin])
    }

    pub enum FromExpressionOrJoin with Eq, ToString {
        case FromExpression(FromExpression, Option[TableAlias], Option[TableSample])
        case Join(ParensB, JoinClause, Option[String])
    }


    pub enum FromExpression with Eq, ToString {
        case TableReference(QualifiedName)
        case TableFunction(QualifiedName, List[Expression])
        case Subquery(SelectStmt)
        case Values(ValuesClause)
    }

    pub enum JoinClause with Eq, ToString {
        case JoinClause(TableOrSubquery, Option[JoinDesignation], TableOrSubquery, Option[JoinCondition])
    }

    pub enum TableOrSubquery with Eq, ToString {
        case Table(String)
        case Subquery(SelectStmt)
    }


    pub enum JoinDesignation with Eq, ToString {
        case Join(Option[NaturalOrAsOf], JoinType)
        case Positional
        case Cross
    }

    pub enum JoinCondition with Eq, ToString {
        case On(Expression)
        case Using(List[String])
    }

    pub enum NaturalOrAsOf with Eq, ToString {
        case Natural
        case AsOf
    }

    pub enum JoinType with Eq, ToString {
        case Inner
        case Left(Option[OuterJoin])
        case Right(Option[OuterJoin])
        case Full(Option[OuterJoin])
    }

    pub enum OuterJoin with Eq, ToString {
        case OuterJoin
    }

    pub enum TableAlias with Eq, ToString {
        case TableAlias(AsB, String, Option[List[String]])
    }

    pub enum TableSample with Eq, ToString {
        case SizeFirst(Int32, Option[PercentOrRow], Option[(SamplingMethod, Option[Int32])])
        case FunctionStyle(Option[SamplingMethod], Int32, Option[PercentOrRow], Option[Int32])
    }

    // `Precent(true)` to show as `%`
    pub enum PercentOrRow with Eq, ToString {
        case Percent(AsSymbolB)
        case Row
    }

    pub enum SamplingMethod with Eq, ToString {
        case Reservoir
        case Bernoulli
        case System
    }

    pub enum WhereClause with Eq, ToString {
        case WhereClause(Expression)
    }

    pub enum GroupByClause with Eq, ToString {
        case GroupBy(List[Grouping])
        case GroupByAll
    }

    pub enum Grouping with Eq, ToString {
        case GroupingExpr(Expression)
        case GroupingSets(List[List[Expression]])
        case GroupingSimple(CubeOrRollup, List[Expression])
    }

    pub enum CubeOrRollup with Eq, ToString {
        case Cube
        case Rollup
    }

    pub enum HavingClause with Eq, ToString {
        case HavingClause(Expression)
    }

    pub enum WindowClause with Eq, ToString {
        case WindowClause(List[(String, WindowDefinition)])
    }

    pub enum WindowDefinition with Eq, ToString {
        case WindowDefinition(Option[String], Option[PartitionByClause], Option[OrderByClause], FrameSpec)
    }

    pub enum PartitionByClause with Eq, ToString {
        case PartitionByClause(List[Expression])
    }

    pub enum FrameSpec with Eq, ToString {
        case FrameSpec(RangeOrRows, FrameBody, Option[WindowExclude])
    }

    pub enum RangeOrRows with Eq, ToString {
        case Range
        case Rows
    }

    pub enum FrameBody with Eq, ToString {
        case Between(FrameStart, FrameStop)
        case UnboundedPreceding
        case Preceding(Expression)
        case CurrentRow
    }

    pub enum FrameStart with Eq, ToString {
        case UnboundedPreceding
        case Preceding(Expression)
        case CurrentRow
        case Following(Expression)
    }

    pub enum FrameStop with Eq, ToString {
        case Preceding(Expression)
        case CurrentRow
        case Following(Expression)
        case UnboundedFollowing
    }

    pub enum WindowExclude with Eq, ToString {
        case CurrentRow
        case Group
        case Ties
        case NoOthers
    }

    pub enum QualifyClause with Eq, ToString {
        case QualifyClause(Expression)
    }


    pub enum OrderByClause with Eq, ToString {
        case OrderByExprs(List[(Expression, OrderDesignation)])
        case OrderByAll(OrderDesignation)
    }

    pub enum OrderDesignation with Eq, ToString {
        case OrderDesignation(Option[SortOrder], Option[NullsPosition])
    }

    pub enum SortOrder with Eq, ToString, Order {
        case Asc
        case Desc
    }

    pub enum NullsPosition with Eq, ToString, Order {
        case First
        case Last
    }

    pub enum LimitClause with Eq, ToString {
        case LimitClause(Expression, Option[Expression])
    }

    pub enum SqlType with Eq, ToString {
        case Varchar
        case Integer
    }



}
