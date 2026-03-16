import { serve } from 'https://deno.land/std@0.210.0/http/server.ts';

const RUPANTOR_API_KEY = 'W5bpbja0h0te8oOo5bD9h8qCcneMsXkJ5RgCjggYuJedWUL6FM';
const RUPANTOR_API_URL = 'https://api.rupantor.com/v1/payments';

serve(async (req: Request) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };

  if (req.method === 'OPTIONS') {
    return new Response(JSON.stringify({ ok: true }), { status: 204, headers });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405, headers });
  }

  let body: any;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: 'Invalid JSON body' }), { status: 400, headers });
  }

  const { product_name, amount, customer_email, order_id } = body;
  if (!product_name || !amount || !customer_email || !order_id) {
    return new Response(
      JSON.stringify({ error: 'Missing required fields: product_name, amount, customer_email, order_id' }),
      { status: 400, headers }
    );
  }

  try {
    const origin = req.headers.get('origin') || 'https://lovable.shop';
    const payload = {
      product_name,
      amount,
      customer_email,
      order_id,
      currency: 'BDT',
      success_url: `${origin}/payment-success?order_id=${encodeURIComponent(order_id)}`,
      cancel_url: `${origin}/payment-cancel?order_id=${encodeURIComponent(order_id)}`,
      metadata: {
        order_id,
      },
    };

    const createResponse = await fetch(RUPANTOR_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${RUPANTOR_API_KEY}`,
      },
      body: JSON.stringify(payload),
    });

    const createData = await createResponse.json();

    if (!createResponse.ok) {
      console.error('Rupantor Pay create payment error', createData);
      return new Response(JSON.stringify({ error: 'Failed to create Rupantor payment', details: createData }), {
        status: 502,
        headers,
      });
    }

    const paymentUrl = createData.payment_url ?? createData.data?.payment_url ?? createData.checkout_url;
    if (!paymentUrl) {
      console.error('Rupantor Pay missing payment_url', createData);
      return new Response(JSON.stringify({ error: 'Rupantor Pay response did not include payment_url', details: createData }), {
        status: 502,
        headers,
      });
    }

    return new Response(JSON.stringify({ payment_url: paymentUrl }), {
      status: 200,
      headers,
    });
  } catch (error) {
    console.error('create-payment function error', error);
    return new Response(JSON.stringify({ error: 'Internal server error' }), {
      status: 500,
      headers,
    });
  }
});
