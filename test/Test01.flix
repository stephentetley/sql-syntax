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

    use SqlSyntax.Datatypes.{SqlType}
    use SqlSyntax.Datatypes.QualifiedName.{QualifiedName, UnqualifiedName}
    use SqlSyntax.Datatypes.Expression.{Literal}
    use SqlSyntax.Datatypes.Literal.{Integer, Varchar}
    use SqlSyntax.Datatypes.CreateTableStmt.{CreateTableStmt}
    use SqlSyntax.Datatypes.DropStmt.{DropStmt}
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
    use SqlSyntax.Datatypes.OnConflictClause.{OnConflictClause}
    use SqlSyntax.Datatypes.DoUpdateOrDoNothing.{DoUpdate, DoNothing}
    use SqlSyntax.Datatypes.ReturningClause.{ReturningClause}
    use SqlSyntax.Datatypes.InsertValuesClause.{ValuesIVC, DefaultValuesIVC}
    use SqlSyntax.Datatypes.SqlType.{VarcharType, IntegerType}

    @test
    def test01(): Unit \ IO = 
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppSqlType(VarcharType)))


    @test
    def test02(): Unit \ IO = 
        let src = CreateTableStmt(true, false, true, UnqualifiedName("edge"), 
                        List#{("from_edge", Column(VarcharType, List#{AllowNullCC(false)})), ("to_edge", Column(VarcharType, List#{AllowNullCC(false)}))}, 
                        List#{PrimaryKeyTC(List#{"from_edge", "to_edge"})});
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppCreateTableStmt(src)))

    @test
    def test03(): Unit \ IO = 
        let src = DropStmt(TableDQ, true, UnqualifiedName("edge"), Some(CascadeCR));
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppDropStmt(src)))

    @test
    def test04(): Unit \ IO = 
        let src = InsertStmt(Some(OrIgnoreIQ), UnqualifiedName("edge"), Some(UnqualifiedName("result")), 
                        List#{"from_edge", "to_edge"}, 
                        Some(ByNameICQ), 
                        ValuesIVC(List#{List#{Literal(Integer(1)), Literal(Integer(2))}}),
                        Some(OnConflictClause(List#{"from_edge", "to_edge"}, None, DoNothing)),
                        Some(ReturningClause(true, Nil)));
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppInsertStmt(src)))

}
