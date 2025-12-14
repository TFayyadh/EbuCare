import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

serve(async (req) => {
  try {
    const {
      to,
      booking_id,
      description,
      amount_myr,
      payment_intent_id,
    } = await req.json();

    if (!to || !booking_id || !amount_myr) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400 }
      );
    }

    const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
    if (!RESEND_API_KEY) {
      return new Response(
        JSON.stringify({ error: "Missing RESEND_API_KEY" }),
        { status: 500 }
      );
    }

    // 📧 Email content
    const html = `
      <div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>Payment Invoice - EbuCare</h2>
        <p>Thank you for your payment.</p>

        <table cellpadding="6">
          <tr>
            <td><strong>Booking ID</strong></td>
            <td>${booking_id}</td>
          </tr>
          <tr>
            <td><strong>Service</strong></td>
            <td>${description}</td>
          </tr>
          <tr>
            <td><strong>Amount Paid</strong></td>
            <td>RM ${amount_myr}</td>
          </tr>
          <tr>
            <td><strong>Payment Reference</strong></td>
            <td>${payment_intent_id ?? "-"}</td>
          </tr>
        </table>

        <p style="margin-top:20px;">
          If you have any questions, please contact EbuCare support.
        </p>

        <p>— EbuCare Team</p>
      </div>
    `;

    // 🚀 Send email via Resend
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "EbuCare <onboarding@resend.dev>",
        to: [to],
        subject: "Your Payment Invoice - EbuCare",
        html,
      }),
    });

    if (!res.ok) {
      const err = await res.text();
      return new Response(
        JSON.stringify({ error: err }),
        { status: 500 }
      );
    }

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200 }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500 }
    );
  }
});
