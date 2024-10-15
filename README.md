# Conga App

Phoenix/Ash Full-Stack Blog Application

Welcome to my cutting-edge full-stack blog application built on the BEAM VM, leveraging the power of Phoenix, LiveView, and Ash Framework. This project showcases a modern web application architecture, integrating advanced features and technologies to deliver a robust, scalable, and feature-rich blogging platform.

## 🌟 Features

- **Blog Engine**: Full-featured blog with posts, categories, and tags
- **Comment System**: Rich, real-time commenting functionality
- **User Management**: Authentication, profiles, and role-based access control
- **Bookmarking**: Allow users to save and organize their favorite content
- **Analytics Dashboard**: Insights into user engagement and content performance
- **API Support**: Both RESTful JSON API and GraphQL API
- **Search Engine**: Built-in tools for improving search
- **E-commerce Integration**: Basic store functionality for digital products
- **Admin Panel**: Comprehensive dashboard for content and user management

## 🏗️ Architecture

My application is built on a modern, scalable architecture:

- **Phoenix Framework**: Powers the web layer, providing a robust foundation
- **LiveView**: Enables real-time, interactive user experiences without complex JavaScript
- **Ash Framework**: Drives the application layer, offering a declarative and extensible approach to building APIs and services
- **PostgreSQL with TimescaleDB**: The primary datastore, enhanced with time-series capabilities
- **Object Storage**: Efficient handling of media and large binary objects

## 🚀 Getting Started

To get the application up and running:

1. Ensure you have Elixir, Erlang, and PostgreSQL installed
2. Clone the repository: `git clone https://github.com/mburuwarui/conga.git`
3. Navigate to the project directory: `cd conga`
4. Install dependencies: `mix deps.get`
5. Set up the database: `mix ash.setup`
6. Start the Phoenix server: `mix phx.server`

Visit `http://localhost:4000` in your browser to see the application in action!

## 📚 Documentation

- [Phoenix Framework](https://hexdocs.pm/phoenix/overview.html)
- [Ash Framework](https://www.ash-hq.org/)
- [LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)

## 🛠️ Development

This project uses Ash resources as the core building blocks of the application. Resources define the schema, API endpoints, state machines, and more. Here's a brief overview of our key resources:

- `Posts.Post`: Manages blog post creation, updates, and retrieval
- `Posts.Comment`: Handles comment functionality
- `Accounts.User`: User management and authentication
- `Posts.Bookmark`: User bookmarking system
- `Store.Product`: E-commerce product management

## 🌐 API

Our application exposes both REST and GraphQL APIs:

- REST API Playground: Available at `http://localhost:4000/api/json/swaggerui`
- GraphQL API Playground: Available at `http://localhost:4000/gql/playground`

Detailed API documentation can be found in the `/docs` directory.

## 🧪 Testing

Run the test suite with:

```elixir
mix test
```
