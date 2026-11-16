# Before/after examples

## Guard clauses and named constants

Before:
```js
function getDiscount(user) {
  if (user) {
    if (user.isPremium) {
      return 0.2;
    } else {
      return 0.05;
    }
  }
  return 0;
}
```

After:
```js
const PREMIUM_DISCOUNT = 0.2;
const STANDARD_DISCOUNT = 0.05;

export function getDiscount(user) {
  if (!user) return 0;
  return user.isPremium ? PREMIUM_DISCOUNT : STANDARD_DISCOUNT;
}
```

## Promise chains → async/await, with real error handling

Before:
```js
function loadUser(id) {
  return fetch('/api/users/' + id)
    .then(res => res.json())
    .then(data => {
      return data;
    })
    .catch(err => {});
}
```

After:
```js
export async function loadUser(id) {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) {
    throw new Error(`Failed to load user ${id}: ${response.status}`);
  }
  return response.json();
}
```

## Sequential awaits → Promise.all

Before:
```js
const user = await fetchUser(id);
const orders = await fetchOrders(id);
const settings = await fetchSettings(id);
```

After:
```js
const [user, orders, settings] = await Promise.all([
  fetchUser(id),
  fetchOrders(id),
  fetchSettings(id),
]);
```

## Positional parameters → options object

Before:
```js
createUser('Ada', 'ada@example.com', true, false, 'admin');
```

After:
```js
createUser({
  name: 'Ada',
  email: 'ada@example.com',
  role: 'admin',
  isVerified: true,
  sendWelcomeEmail: false,
});
```

## Mutation → returning new values

Before:
```js
function activateAll(users) {
  for (let i = 0; i < users.length; i++) {
    users[i].active = true;
  }
  return users;
}
```

After:
```js
export function activateAll(users) {
  return users.map((user) => ({ ...user, active: true }));
}
```

## Nested ternary → lookup object

Before:
```js
const label = status === 'a' ? 'Active' : status === 'p' ? 'Pending' : status === 'x' ? 'Closed' : 'Unknown';
```

After:
```js
const STATUS_LABELS = {
  a: 'Active',
  p: 'Pending',
  x: 'Closed',
};

const label = STATUS_LABELS[status] ?? 'Unknown';
```

## React: derived state instead of syncing with useEffect

Before:
```jsx
function Cart({ items }) {
  const [total, setTotal] = useState(0);
  useEffect(() => {
    setTotal(items.reduce((sum, item) => sum + item.price, 0));
  }, [items]);
  return <p>Total: {total}</p>;
}
```

After:
```jsx
export function Cart({ items }) {
  const total = items.reduce((sum, item) => sum + item.price, 0);
  return <p>Total: {total}</p>;
}
```

## Express: thin handler

Before:
```js
app.post('/orders', async (req, res) => {
  try {
    if (!req.body.items || req.body.items.length == 0) {
      res.status(400).send('bad');
      return;
    }
    // ...40 lines of pricing, DB writes, and email sending...
  } catch (e) {
    console.log(e);
    res.status(500).send('error');
  }
});
```

After:
```js
app.post('/orders', async (req, res, next) => {
  try {
    const input = orderSchema.parse(req.body);
    const order = await createOrder(input);
    res.status(201).json(order);
  } catch (err) {
    next(err);
  }
});
```
