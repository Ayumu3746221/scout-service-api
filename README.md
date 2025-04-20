# README

## 開発環境

- Ruby 3.4.2
- Rails 8.0.2
- PostgreSQL 15

## 設計

### 既存サービスの足りてない所

- 長期インターンを取り扱っているのに学生の大学院進学を視野に入れていない
- 自己紹介等を書かせるのにエクセル等で出力できない（ユーザーの PC に保存できない）

-> 上記二つはかなり不満

### 仕様

DB は /docs/erd.plantuml を参考に

- authentication（認証機能）

  1. User の種類は {student , recuiter}
  2. student は /signup で登録できる
     リクエスト例

  ```json
  {
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "role": "student"
    }
  }
  ```

  3.  company 最初の recuiter は company と一緒に登録できる
      リクエスト例

      ```json
      {
        "company": {
          "name": "Example Company",
          "email": "example@company.com",
          "industry_id": 1
        },
        "user": {
          "email": "recruiter@example.com",
          "password": "password123",
          "password_confirmation": "password123"
        },
        "recruiter": {
          "name": "John Recruiter"
        }
      }
      ```

  4.  二人目の recuiter からは recuiter の権利がある User しか生成できない
  5.  iv.の時に作成された recuiter は作成した recuiter と同一の company を持つ

- **student の仕様**

- プロフィールを変更する

  1. ログイン(student role)していないと変更不可
  2. 自分自身のプロフィールしか変更できない

  ```json
  // リクエスト例
  {
    "student": {
      "name": "next_user",
      "introduce": "B3/情報系",
      "graduation_year": 2025,
      "school": "example university",
      "portofolio_url": "http/example.com/portofolio",
      "industry_ids": [1, 2, 3]
    }
  }
  ```

- プロフフィールを取得する

  1. 他者も確認できる

  ```json
  // response例
  {
    "user_id": 1,
    "name": "next_user",
    "introduce": "B3/情報系",
    "graduation_year": 2025,
    "school": null,
    "portfolio_url": null,
    "industries": [
      {
        "id": 1,
        "name": "IT"
      },
      {
        "id": 2,
        "name": "Finance"
      },
      {
        "id": 3,
        "name": "Healthcare"
      }
    ],
    "skills" : [
      {
        "id": 1,
        "name": "Ruby on Rails"
      }
    ]
  },
  ```

**skills の仕様**

- マスターテーブルの為、GET のみ実装

  GET : /api/v1/skills

  ```json
  // レスポンス例
  [
    {
      "id": 1,
      "name": "Ruby"
    },
    {
      "id": 2,
      "name": "JavaScript"
    }
  ]
  ```
