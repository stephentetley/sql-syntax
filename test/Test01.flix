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
    use SqlSyntax.Datatypes.CreateTableStmt.{CreateTableStmt}
    use SqlSyntax.Datatypes.DropStmt.{DropStmt}
    use SqlSyntax.Datatypes.SqlType.{Varchar}
    use SqlSyntax.Datatypes.QualifiedName.{UnqualifiedName}
    use SqlSyntax.Datatypes.ColumnSpec.{Column, GeneratedColumn}
    use SqlSyntax.Datatypes.ColumnConstraint.{PrimaryKeyCC, AllowNullCC, UniqueCC, CheckCC, DefaultCC, ReferencesCC, CollateCC}
    use SqlSyntax.Datatypes.TableConstraint.{PrimaryKeyTC, UniqueTC, CheckTC, ForeignKeyTC}
    use SqlSyntax.Datatypes.DropQualifier.{FunctionDQ, IndexDQ, MacroDQ, SchemaDQ, SequenceDQ, TableDQ, ViewDQ, TypeDQ}
    use SqlSyntax.Datatypes.DropClause.{CascadeDC, RestrictDC}

    @test
    def test01(): Unit \ IO = 
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppSqlType(Varchar)))


    @test
    def test02(): Unit \ IO = 
        let src = CreateTableStmt(true, false, true, UnqualifiedName("edge"), 
                        List#{("from_edge", Column(Varchar, List#{AllowNullCC(false)})), ("to_edge", Column(Varchar, List#{AllowNullCC(false)}))}, 
                        List#{PrimaryKeyTC(List#{"from_edge", "to_edge"})});
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppCreateTableStmt(src)))

    @test
    def test03(): Unit \ IO = 
        let src = DropStmt(TableDQ, false, UnqualifiedName("edge"), Some(CascadeDC));
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppDropStmt(src)))

}
