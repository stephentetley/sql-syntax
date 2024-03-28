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

mod Test01 {

    use SqlSyntax.Datatypes.{SqlType, ColumnConstraint, TableConstraint, DropQualifier, 
        CascadeOrRestrict, InsertQualifier, InsertColumnQualifier, InsertValuesClause, 
        DoUpdateOrDoNothing, OrReplace, Temporary, IfNotExists, IfExists, 
        ReturnExpression}

    use SqlSyntax.Datatypes.QualifiedName.{QualifiedName, UnqualifiedName}
    use SqlSyntax.Datatypes.Expression.{Literal}
    use SqlSyntax.Datatypes.Literal.{Integer, Varchar}
    use SqlSyntax.Datatypes.CreateTableStmt.{CreateTableStmt}
    use SqlSyntax.Datatypes.DropStmt.{DropStmt}
    use SqlSyntax.Datatypes.CreateTableStmt.{CreateTableStmt}
    use SqlSyntax.Datatypes.ColumnSpec.{Column, GeneratedColumn}
    use SqlSyntax.Datatypes.DropStmt.{DropStmt}
    use SqlSyntax.Datatypes.InsertStmt.{InsertStmt}
    use SqlSyntax.Datatypes.OnConflictClause.{OnConflictClause}
    use SqlSyntax.Datatypes.ReturningClause.{ReturningClause}
    use SqlSyntax.Datatypes.ValuesClause.{ValuesClause}

    @test
    def test01(): Unit \ IO = 
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppSqlType(SqlType.Varchar)))


    @test
    def test02(): Unit \ IO = 
        let src = CreateTableStmt(Some(OrReplace.OrReplace), Some(Temporary.Temp), 
                        Some(IfNotExists.IfNotExists), UnqualifiedName("edge"), 
                        List#{("from_edge", Column(SqlType.Varchar, List#{ColumnConstraint.AllowNull(false)})), 
                                ("to_edge", Column(SqlType.Varchar, List#{ColumnConstraint.AllowNull(false)}))}, 
                        List#{TableConstraint.PrimaryKey(List#{"from_edge", "to_edge"})});
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppCreateTableStmt(src)))

    @test
    def test03(): Unit \ IO = 
        let src = DropStmt(DropQualifier.Table, Some(IfExists.IfExists), UnqualifiedName("edge"), Some(CascadeOrRestrict.Cascade));
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppDropStmt(src)))

    @test
    def test04(): Unit \ IO = 
        let src = InsertStmt(Some(InsertQualifier.OrIgnore), UnqualifiedName("edge"), Some(UnqualifiedName("result")), 
                        List#{"from_edge", "to_edge"}, 
                        Some(InsertColumnQualifier.ByName), 
                        InsertValuesClause.Values(ValuesClause(List#{List#{Literal(Integer(1)), Literal(Integer(2))}})),
                        Some(OnConflictClause(List#{"from_edge", "to_edge"}, None, DoUpdateOrDoNothing.DoNothing)),
                        Some(ReturningClause(List#{ReturnExpression.ReturnStar})));
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppInsertStmt(src)))

}
