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
    use SqlSyntax.Datatypes.SqlType.{Varchar}
    use SqlSyntax.Datatypes.QualifiedTableName.{UnqualifiedTableName}

    @test
    def test01(): Unit \ IO = 
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppSqlType(Varchar)))


    @test
    def test02(): Unit \ IO = 
        let src = CreateTableStmt(true, false, true, UnqualifiedTableName("edge"), List#{}, List#{});
        println(Text.PrettyPrint.render(100, SqlSyntax.Pretty.ppCreateTableStmt(src)))


}
